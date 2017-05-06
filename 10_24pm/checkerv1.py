'''
A code checker tool for Java, C, CPP. Gives feedback of compile error/runtime error/accepted/wrong/TLE
'''

import os, filecmp, subprocess, csv, sys, shutil


def compile(fileName, lang):
    if lang == 'c':
        outFile = fileName[:-2]
    elif lang == 'cpp':
        outFile = fileName[:-4]
    elif lang == 'java':
        outFile = fileName[:-4] + 'class'
    #If file with same name exists already, remove it
    if os.path.isfile(outFile):
        os.remove(outFile)
    if lang == 'java':
        printFile = outFile[-6]
    else:
        printFile = fileName
    #Try to compile the file
    if os.path.isfile(fileName):
        try:
            if lang == 'java':
                compile_out = subprocess.check_output('javac ' + fileName, stderr=open('temp/'+printFile+'_compile_err.txt', 'w'), shell=True)
            elif lang == 'c' or lang == 'cpp':
                compile_out = subprocess.check_output('g++ -o ' + outFile + ' ' + fileName, stderr=open('temp/'+printFile+'_compile_err.txt', 'w'), shell=True)
        except subprocess.CalledProcessError as e:
            err = 'Compile error'

        with open('temp/'+printFile+'_compile_err.txt', 'r') as compile_file:
            compile_err = compile_file.read()

        if os.path.isfile(outFile):
            return 1, outFile
        else:
            return -1, compile_err
    else:
        return -2, 'No file named '+fileName+'found in the current directory'


def run(fileName, inputFile, timeout, lang):
    if lang == 'java':
        cmd = 'java ' + fileName[-6]
    elif lang == 'c' or lang == 'cpp':
        cmd = './' + fileName

    if lang == 'java':
        outFile = fileName[-6]
    else:
        outFile = fileName
    outFile += '_out.txt'
    outFile = 'temp/' + outFile

    # terminal_cmd = os.system('timeout '+timeout+' '+cmd+' < '+inputFile+' > '+outFile)
    # if terminal_cmd == 32512:
    try: 
        if sys.platform == 'darwin':
            terminal_cmd = subprocess.check_output('function timeout() { perl -e \'alarm shift; exec @ARGV\' "$@";} ;' + 'timeout '+timeout+' '+cmd+' < '+inputFile+' > '+outFile, stderr = open('temp/'+inputFile+'_runtime_err.txt', 'w'), shell=True)
        if sys.platform == 'linux' or sys.platform == 'linux2':
            terminal_cmd = subprocess.check_output('timeout '+timeout+' '+cmd+' < '+inputFile+' > '+outFile, stderr = open('temp/'+inputFile+'_runtime_err.txt', 'w'), shell=True)

    except subprocess.CalledProcessError as e:
        with open('temp/'+inputFile+'_runtime_err.txt', 'r') as runtime_file:
            runtime_err = runtime_file.read()
            if runtime_err.find('Alarm') == -1:
                if lang == 'java':
                    os.remove(fileName)
                elif lang == 'c' or lang == 'cpp':
                    os.remove(fileName)

                return -3, runtime_err

            else:
                if lang == 'java':
                    os.remove(fileName+'.class')
                elif lang == 'c' or lang == 'cpp':
                    os.remove(fileName)

                return -4, 'Timeout'


    # Remove all extraneous files produced
    if lang == 'java':
        os.remove(fileName+'.class')
    elif lang == 'c' or lang == 'cpp':
        os.remove(fileName)
    if terminal_cmd == '':
        return 1, 'Ran successfully'
    else:
        return -2, 'File not found in current directory'


def calcScore(correct_output_file, subm_output_file, verbose=False):
    wrongOutput = []
    score = 0
    count = 0
    with open(correct_output_file, 'r') as correct_file:
        correct_output = correct_file.readlines()
    with open('temp/'+subm_output_file, 'r') as subm_file:
        subm_output = subm_file.readlines()
    num_testcases = len(correct_output)
    report = ''
    for correct_val, subm_val in zip(correct_output, subm_output):
        # print correct_val, subm_val
        count += 1
        if correct_val == subm_val:
            score += 1
        else:
            wrongOutput.append(count)
            report = report + '\nTest case: ' + str(count) + '\nExpected: ' + str(correct_val) + '\nSubmitted: ' + str(subm_val) 
            if verbose:
                print 'Test case:', count
                print 'Expected:', correct_val
                print 'Submitted:', subm_val
                print '\n'

    return (score, num_testcases, report)

def printScore(fileName, testin, testout, timeout, lang):
    compile_code, compile_prompt = compile(fileName, lang)
    compiled, ran = False, False
    if compile_code == 1:
        compiled = True
    else:
        compile_report = compile_prompt
        return compiled, ran, 'NA', compile_report, 'NA', 'NA'
    run_code, run_prompt = run(compile_prompt, testin, timeout, lang)
    if run_code == 1:
        ran = True
    elif run_code == -4:
        return compiled, 'Timeout', 'NA', 'No compile time errors', 'Timeout: Taking too long', 'NA'
    else:
        runtime_report = run_prompt
        return compiled, ran, 'NA', 'No compile time errors', runtime_report, 'NA'
    score, num_testcases, run_report = calcScore(testout, compile_prompt+'_out.txt', verbose=True)
    return compiled, ran, score, 'No compile time errors', 'No runtime errors', run_report
    # print 'score/num_testcases:', str(score)+"/"+str(num_testcases)

if __name__ == '__main__':

    subm_dir = sys.argv[3]+'/uploaded_files/'+sys.argv[1]+'/'+sys.argv[2]
    print subm_dir
    subm_folder, testin, testout, timeout = subm_dir, 'test.txt', 'out.txt', '2'
    os.chdir(subm_folder)

    scores = {}
    if not os.path.isdir('temp'):
        os.mkdir('temp')

    for subm in os.listdir(subm_folder):
        lang = ''
        if subm.endswith('.c'):
            lang = 'c'
        elif subm.endswith('.cpp'):
            lang = 'cpp'
        elif subm.endswith('.java'):
            lang = 'java'
        else:
            continue
        compiled, ran, score, compile_report, runtime_report, run_report = printScore(subm, testin, testout, timeout, lang)
        scores[subm] = map(str, (compiled, ran, score, compile_report, runtime_report, run_report))
        
    with open('scores.csv', 'w') as scoreFile:
        writer = csv.writer(scoreFile)
        writer.writerow(('FileName', 'Compiled successfully', 'Ran successfully', 'Score'))
        for k, v in scores.iteritems():
            writer.writerow([k] + v[:3])

    with open('Report.txt', 'w') as reportFile:
        for k, v in scores.iteritems():
            reportFile.write(str(k)+'\n\n')
            reportFile.write('\nCompilation errors:\n')
            reportFile.write(str(v[3])+'\n')
            print v[3], len(v[3]), v[3][0]
            reportFile.write('\nRun-time errors:\n')
            reportFile.write(str(v[4])+'\n')
            reportFile.write('\nWrong output on testcases:\n')
            reportFile.write(str(v[5])+'\n\n')
            reportFile.write('****************************************\n')

    with open('Plag_Report.txt', 'w') as plagFile:
        report = subprocess.check_output('./moss -d '+ subm_dir + '/*.c /*.cpp', stderr=open('plag_err.txt', 'w'), shell=True)
        plag_err = open('plag_err.txt', 'r').read()
        report += str(plag_err)
        plagFile.write(report)
    # shutil.rmtree('temp')


