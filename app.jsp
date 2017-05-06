/****************************************************************************************

  If this file runs properly and connects to mongo database you will be able to see
 
  Example aapp listening on port 3000!
  successfully connected to mongodb
  successfully connected to mongodb

  in the console you started the server
  
  If you are able to see this on the console, the server started and you can run the application :)

  

  If not probable errors that may occur while running node.js file are listed in the errors_may_be_nodejs file

//To run this present node and mongodb has to be installed in your(the) system
//Instructions for the installation of node js and mongo db is detailed in the file 'readme_node_and_mongodb_install'
//The server system  need to contain java,c,c++,python compilers and run time environments.

*********************************************************************************************/



// the following node modules from express to string need to be installed for working with the present app.js file
var express = require('express');
var mongoose = require('mongoose');
var logger = require('morgan');
var cookieParser = require('cookie-parser');
var bodyParser = require('body-parser');
var path    = require('path');
var sessions = require('client-sessions');
var fs = require('fs')
var unzip = require('unzip')
var mkdir = require('mkdirp')
var extract = require('extract-zip')
var AdmZip = require('adm-zip');
var PythonShell = require('python-shell');
const fileUpload = require('express-fileupload');
var formidable = require('formidable');
var S = require('string');

//stroring uploadfiles path in dir
var dir = './uploaded_files/';

//here using express js framework
var app = express();



//setting app parameters. for example static file paths 
app.use(express.static(__dirname + '/public'));
app.use(logger('dev'));
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));
app.use(cookieParser());


//maintaining client sessions using sessions
app.use(sessions({
  cookieName: 'session',
  secret: 'rgebjiuVihB5U7owfghij2ihBIUB334I765UHIojkbB',
  duration: 30 * 60 * 1000,
  activeDuration: 5 * 60 * 1000,
}));


//connecting to mongodb database (this mongodb runs on the port 27017)
var user_database = mongoose.createConnection('mongodb://localhost/test',function (err) {
  if(err){
    return console.log(err);
  }else {
    return console.log('successfully connected to mongodb');
  }
});

var admin_database = mongoose.createConnection('mongodb://localhost/test1',function (err) {
  if(err){
    return console.log(err);
  }else {
    return console.log('successfully connected to mongodb');
  }
});

//defining schema for the databases
var user_mySchema =mongoose.Schema({
  username: {type: String, unique: true},
  password: {type: String},
  firstname: String,
  lastname: String
});

var admin_mySchema =mongoose.Schema({
  username: {type: String, unique: true},
  password: {type: String}
});


//defining model for the database
var User = user_database.model('users',user_mySchema);

var Admin = admin_database.model('users1',admin_mySchema);


//routing to the home page 
app.get('/', function (req, res) {
  //checking sessions
if(!req.session.admin){   
  if(req.session && req.session.user){
    User.findOne({username: req.session.user.username},function(err,user){
      if(!user){
        req.session.reset();
        res.sendFile(path.join(__dirname+'/public/login.html'));
      }else{
        res.locals.user = user;
        res.redirect('/dashboard');
      }
    });
  }else{
  //  res.send(req.session.user);
  //sending login files
    res.sendFile(path.join(__dirname+'/public/login.html'));
  }
  }else{
    //redirecting to dashboard
  res.redirect('/admin_dashboard');
  }

});

//if the "get" method gets the login 
app.get('/login',function (req,res,next) {
if(!req.session.admin){		
  if(req.session && req.session.user){
    User.findOne({username: req.session.user.username},function(err,user){
      if(!user){
        req.session.reset();
        res.sendFile(path.join(__dirname+'/public/login.html'));
      }else{
        res.locals.user = user;
        res.redirect('/dashboard');
      }
    });
  }else{
    res.sendFile(path.join(__dirname+'/public/login.html'));
  }
  }else{
	res.redirect('/admin_dashboard');
	}
});

//admin login
//many functionalities like forgot password , deleting user etc.. are added
app.get('/admin_login',function (req,res,next) {
if(!req.session.user){
	if(req.session && req.session.admin){
    	Admin.findOne({username: req.session.admin.username},function(err,admin){
    		if(!admin){
    	        req.session.reset();
        		res.sendFile(path.join(__dirname+'/public/login.html'));
    		}else{
    			res.locals.admin = admin;
        		res.redirect('/admin_dashboard');
    		}
    	});
    }else{
    	res.sendFile(path.join(__dirname+'/public/admin_login.html'));
    }
}else{
	res.redirect('/admin_dashboard');
}   		
});


app.get('/deleting_user',function (req,res,next) {
if(!req.session.user){
	if(req.session && req.session.admin){
    	Admin.findOne({username: req.session.admin.username},function(err,admin){
    		if(!admin){
    	        req.session.reset();
        		res.sendFile(path.join(__dirname+'/public/login.html'));
    		}else{
    			res.locals.admin = admin;
        		res.sendFile(path.join(__dirname+'/public/remove_account.html'));
    		}
    	});
    }else{
    	res.sendFile(path.join(__dirname+'/public/admin_login.html'));
    }
}else{
	res.redirect('/admin_dashboard');
}  

});


app.get('/forgot_password',function (req,res,next) {
if(!req.session.admin){		
  if(req.session && req.session.user){
    User.findOne({username: req.session.user.username},function(err,user){
      if(!user){
        req.session.reset();
        res.sendFile(path.join(__dirname+'/public/forgot_password.html'));
      }else{
        res.locals.user = user;
        res.redirect('/dashboard');
      }
    });
  }else{
    res.sendFile(path.join(__dirname+'/public/forgot_password.html'));
  }
}else{
	res.redirect('/dashboard');
}
});


//sending signup page
app.get('/signup',function (req,res,next) {

if(!req.session.admin){	
	//res.send(req.session.user);
  if(req.session && req.session.user){
    User.findOne({username: req.session.user.username},function(err,user){
      if(!user){
        req.session.reset();
        res.sendFile(path.join(__dirname+'/public/signup.html'));
      }else{
        res.locals.user = user;
        res.redirect('/dashboard');
      }
    });
  }else{
    res.sendFile(path.join(__dirname+'/public/signup.html'));
  }
}else{
	res.redirect('/admin_dashboard');
}
});

//logout facility :p
app.get('/logout',function(req,res){
  req.session.reset();
  res.redirect('/login');
});


//admin dashboard
app.get('/admin_dashboard',function (req,res) {

  if(req.session && req.session.admin){
    Admin.findOne({username: req.session.admin.username},function(err,admin){
      if(!admin){
        req.session.reset();
        res.redirect('/admin_login');
      }else{
        res.locals.admin = admin;
        res.sendFile(path.join(__dirname+'/public/admin_dashboard.html'));
      }
    });
  }else{
    res.redirect('/login');
  }
});



app.get('/dashboard',function (req,res) {

	if(!req.session.admin){
		if(req.session && req.session.user){
    		User.findOne({username: req.session.user.username},function(err,user){
      		if(!user){
        		req.session.reset();
      	  		res.redirect('/login');
      		}else{
        		res.locals.user = user;
        		res.sendFile(path.join(__dirname+'/public/dashboard.html'));
      		}
    	   });
  	    }else{
    	  res.redirect('/login');
  	    }
	}else{
		res.redirect('/admin_dashboard');
	}
});



app.post('/dashboard', function (req, res){
  //checking sessions
  if(!req.session.admin){
    if(req.session && req.session.user){
        User.findOne({username: req.session.user.username},function(err,user){
          if(!user){
            req.session.reset();
              res.redirect('/login');
          }else{  
            //making a folder
            if (!fs.existsSync(dir+req.session.user.username)){
              fs.mkdirSync(dir+req.session.user.username);
            }
            //form for uploading files
            var form = new formidable.IncomingForm();
        	

            form.parse(req);
        	  var filePath;

            if (!fs.existsSync(dir)){
              fs.mkdirSync(dir);
            }

            //uploading the file
            form.on('fileBegin', function (name, file){
                file.path = __dirname + '/uploaded_files/'+req.session.user.username+'/'+ file.name;  		
        		console.log('file path '+ file.path);
            });

            //unzipping the file
            form.on('file', function (name, file){
        		    var zipfile_path = (__dirname+'/uploaded_files/'+req.session.user.username+'/'+file.name).toString();
        		    //getting file name
                fs.createReadStream(zipfile_path).pipe(unzip.Extract({ path:__dirname+'/uploaded_files/'+req.session.user.username }));
                console.log('Uploaded and unzipped' + file.name);
                var stri = 
                fs.writeFile(__dirname + '/uploaded_files/'+req.session.user.username+'/'+req.session.user.username +'.txt', file.name);
            });
            

        	  function function1(){
              //getting the file name 
              fs.readFile(__dirname + '/uploaded_files/'+req.session.user.username+'/'+req.session.user.username +'.txt', 'utf8', function (err,data) {
                    if (err) {
                      return console.log(err);
                    }
                    console.log(data);
                    //getting the uploaded file name without extensions
                    console.log(S(data).between('', '.').s )

                    console.log('copied');
              });      
               //getting the file name and running the python script
              fs.readFile(__dirname + '/uploaded_files/'+req.session.user.username+'/'+req.session.user.username +'.txt', 'utf8', function (err,data) {
                  if (err) {
                    return console.log(err);
                  }
                  console.log(data);
                  //making options to run the python script
                  var options = {
                      mode: 'text',
                      args: [req.session.user.username,S(data).between('', '.').s,__dirname]
                  };
                  //invoking a python shell to run the  python script which will be in the same directory as this(present) file
                  PythonShell.run('checkerv1.py',options, function(error, stdout, stderr) {
                       if (error) {
                        return console.log(error);
                      }else{
                        //no errors in invoking the file
                        console.log('phani-----------------------------------------------------------');
                      }
                  });

                  });             
              res.sendFile(__dirname + '/public/dashboard_downloadOption.html');
        	  }
            //setting timeout for the function to run after above operations are completed
        	setTimeout(function1, 3000);	
        }
      });
    }else{
      //redirecting to the dashboard
      res.redirect('/login');
    }
      }else{
        res.redirect('/admin_dashboard');
      }
});


//downloading option for the report

app.post('/download', function(req, res) {

 
  console.log("came to post download");
  //downloading the report file file from where it will be stored after python script's stored it
  fs.readFile(__dirname + '/uploaded_files/'+req.session.user.username+'/'+req.session.user.username +'.txt', 'utf8', function (err,data) {
         if (err) {
         return console.log(err);
      }
      console.log(data);
      //printing file name without extension in the console      
      console.log(S(data).between('', '.').s )
      console.log('----------');
      res.download(__dirname+'/uploaded_files/'+req.session.user.username+'/'+S(data).between('', '.').s +'/Report.txt');
  }); 

});

//downloading option for the scores
app.post('/download_2', function(req, res) {
 
  console.log("came to post download");
  //downloading the scores.csv file file from where it will be stored after python script's stored it  
  fs.readFile(__dirname + '/uploaded_files/'+req.session.user.username+'/'+req.session.user.username +'.txt', 'utf8', function (err,data) {
         if (err) {
         return console.log(err);
      }
      console.log(data);
      //printing file name without extension in the console
      console.log(S(data).between('', '.').s )
      console.log('----------');
      res.download(__dirname+'/uploaded_files/'+req.session.user.username+'/'+S(data).between('', '.').s +'/scores.csv');
  }); 

});

//downloading option for the plagiarism report
app.post('/download_3', function(req, res) {
 
  console.log("came to post download");
  //downloading the plagiarism report from where it will be stored after python script's stored it  
  fs.readFile(__dirname + '/uploaded_files/'+req.session.user.username+'/'+req.session.user.username +'.txt', 'utf8', function (err,data) {
         if (err) {
         return console.log(err);
      }
      console.log(data);
      //printing file name without extension in the console      
      console.log(S(data).between('', '.').s )
      console.log('----------');
      res.download(__dirname+'/uploaded_files/'+req.session.user.username+'/'+S(data).between('', '.').s +'/Plag_Report.txt');
  }); 

});

//post methods to get the data feom html forms to do the necessay tasks

app.post('/admin_loggingin',function(req,res){

	var username = req.body.username;
  //verifying admin credentials in admin database
	Admin.findOne({username: req.body.username},function(err,admin){
		if(!admin){
      //sending required html file to the client
			res.sendFile(path.join(__dirname+'/public/admin_login_incorrect.html'));
		}else{
			if(req.body.password === admin.password){
				req.session.admin = admin;
				res.redirect('/admin_dashboard')

			}else{
        //sending required html file to the client
				res.sendFile(path.join(__dirname+'/public/admin_login_incorrect.html'));

			}
		}
	});
});



//post logging in
app.post('/loggingin',function (req,res) {
  var username = req.body.username;
//checking user in the database
  User.findOne({username: req.body.username},function (err,user) {
    if(!user){
      res.sendFile(path.join(__dirname+'/public/login_incorrect.html'));
    }else{
      if(req.body.password === user.password){
        req.session.user = user;
        //redirecting to the dashboard
        res.redirect('/dashboard');
      }else{
        //sending required html file to the client
        res.sendFile(path.join(__dirname+'/public/login_incorrect.html'));
      }
    }
  });
});

//user signing up
app.post('/signingup',function (req,res) {
  //getting credentials from the html file
  var username = req.body.username;
  var password = req.body.password;
  var firstname = req.body.firstname;
  var lastname = req.body.lastname;
  var user = new User();

  user.username = username;
  user.password = password;
  user.firstname = firstname;
  user.lastname = lastname;
  //saving databse of the user
  user.save(function (err,savedObject) {
    if(err){
      console.log(err);
      //sending required html file to the client
      res.sendFile(path.join(__dirname+'/public/signup_incorrect.html'));
    }else{
      //sending required html file to the client
      res.sendFile(path.join(__dirname+'/public/login_new_password.html'));
    }
  });
});



app.post('/delete_user',function (req,res) {
  var username = req.body.username;
  User.findOneAndRemove({username: username},function (err,foundObject) {
    if(err){
      console.log(err);
      res.status(500).send();
    }if(!foundObject){
      //sending required html file to the client
      res.send('not able to remove !! may be no user');
    }else {
      //sending required html file to the client
      res.send('successfully removed');
    }
  });
});


//setting new password for the user
app.post('/setting_new_password',function (req,res) {
  var username = req.body.username;
  var password = req.body.password;
  var confirm_password = req.body.confirm_password;

  if(password != confirm_password){
    //sending required html file to the client
    res.sendFile(path.join(__dirname+'/public/forgot_password_incorrect_username_or_password.html'));
  }else {

    //finding if user is present or not
    User.findOne({username: username},function (err,foundObject) {
      if(err){
        console.log(err);
        res.status(500).send();
      }else {

        if(!foundObject){
          //sending required html file to the client
          res.sendFile(path.join(__dirname+'/public/forgot_password_incorrect_username.html'));
        }else {
          if(req.body.password){
            foundObject.password = password;
          }
          //saving the new password to the user in the database
          foundObject.save(function (err,updateObject) {
            if(err){
              console.log(err);
              return res.status(500).send();
            }else {
              res.sendFile(path.join(__dirname+'/public/login_new_password.html')); 	
            }
          });
        }

      }
    });
  }
});


//app listens on port 3000
app.listen(3000, function (err) {
  if(err){
    //error on listening to the port
    console.log('port may be in use : bind exception')
  }else{
    console.log('Example aapp listening on port 3000!');
  }
});


//note: many extra functionalities are added.
