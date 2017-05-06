# SRAK
Automated grader for course assignments


## Description
SRAK expects a zip folder consisting of submission files to be graded and two additional files. A test cases file named test.txt and the correct output file named out.txt. SRAK is accessed using a web-interface and provides a summary report as well as a comprehensive report. The summary report provides information if compile, runtime errors were encountered and provides provides a score for each file. The comprehensive report lists all compile time errors and runtime errrors(also gives timeout if the submission is taking too long). By default, the submission is given 5sec before timing out.

## Project documentation
[System requirements](https://github.com/skywalker-hunter/SRAK/blob/master/System_Requirements_Specification.pdf)

## Code documentation
[Doxygen documentation](https://github.com/skywalker-hunter/SRAK/blob/master/Doxygen_Documentation.pdf)

## Screenshot
<img width="1275" alt="Screenshot" src="https://cloud.githubusercontent.com/assets/13710347/25664149/62ba8dc8-3037-11e7-976b-732965e4df1f.png">


## Contributors
* Sreekar Reddy cs13b1008@iith.ac.in
* Phani Kumar   cs13b1032@iith.ac.in
* Allam Rakesh  cs13b1002@iith.ac.in
* Arish Ojaswi  cs13b1005@iith.ac.in


## Dependencies

### Node modules to be instaled

*  express,    mongoose,         client-sessions,        morgan,        path,       body-parser,    cookie-parser, 
*  adm-zip,    python-shell,     express-fileupload,     formidable,    sleep,      fs-extra,       child_process,
*  fs-sync,    extract-zip,      varstring               string         multer      unzip,          mkdirp,
*  fs

### Python dependencies

* The backend is pure python and so has no dependencies. Python 2 and Python 3 work equally well.


## Installation instructions
[Install node.js] (https://github.com/skywalker-hunter/SRAK/blob/master/installation_nodejs.pdf)
[Possible errors that could happen with installing node.js] (https://github.com/skywalker-hunter/SRAK/blob/master/errors_may_be_nodejs.pdf)
[Run app.js] (https://github.com/skywalker-hunter/SRAK/blob/master/run_appjs.pdf)


