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
var sleep = require('sleep');
var fse = require('fs-extra');
var fsq = require('fs-sync');
var exec = require('child_process').exec;
var varstring = require("varstring");
var S = require('string');
var multer  = require('multer') //filename
var sleep = require('sleep');
var dir = './uploaded_files/';
var port = process.env.PORT || 3001;

var app = express();

//app.use(fileUpload());

app.use(express.static(__dirname + '/public'));
app.use(logger('dev'));
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));
app.use(cookieParser());


app.use(sessions({
  cookieName: 'session',
  secret: 'rgebjiuVihB5U7owfghij2ihBIUB334I765UHIojkbB',
  duration: 30 * 60 * 1000,
  activeDuration: 5 * 60 * 1000,
}));


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

var User = user_database.model('users',user_mySchema);

var Admin = admin_database.model('users1',admin_mySchema);

app.get('/', function (req, res) {
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
    res.sendFile(path.join(__dirname+'/public/login.html'));
  }
  }else{
  res.redirect('/admin_dashboard');
  }

});


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
  //res.send(__dirname);
  
  //res.sendFile('/Users/killer/Desktop/last_login_and_signup/public/remove_account.html');
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


app.get('/logout',function(req,res){
  req.session.reset();
  res.redirect('/login');
});

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
  if(!req.session.admin){
    if(req.session && req.session.user){
        User.findOne({username: req.session.user.username},function(err,user){
          if(!user){
            req.session.reset();
              res.redirect('/login');
          }else{  
            if (!fs.existsSync(dir+req.session.user.username)){
              fs.mkdirSync(dir+req.session.user.username);
            }
            var form = new formidable.IncomingForm();
        	

            form.parse(req);
        	  var filePath;

            if (!fs.existsSync(dir)){
              fs.mkdirSync(dir);
            }

            form.on('fileBegin', function (name, file){
        		
                file.path = __dirname + '/uploaded_files/'+req.session.user.username+'/'+ file.name;

        		
        		console.log('file path '+ file.path);
            });


            form.on('file', function (name, file){
        		    var zipfile_path = (__dirname+'/uploaded_files/'+req.session.user.username+'/'+file.name).toString();
        		    fs.createReadStream(zipfile_path).pipe(unzip.Extract({ path:__dirname+'/uploaded_files/'+req.session.user.username }));
                console.log('Uploaded and unzipped' + file.name);
                var stri = 
                fs.writeFile(__dirname + '/uploaded_files/'+req.session.user.username+'/'+req.session.user.username +'.txt', file.name);
            });
            

        	  function function1(){
              fs.readFile(__dirname + '/uploaded_files/'+req.session.user.username+'/'+req.session.user.username +'.txt', 'utf8', function (err,data) {
                    if (err) {
                      return console.log(err);
                    }
                    console.log(data);
                    console.log(S(data).between('', '.').s )
                    exec('cp /Users/killer/Desktop/checkerv1.py /Users/killer/Desktop/10_24pm/uploaded_files/'+req.session.user.username+'/'+S(data).between('', '.').s, function(error, stdout, stderr) {});
                    console.log('copied');
              });      
              fs.readFile(__dirname + '/uploaded_files/'+req.session.user.username+'/'+req.session.user.username +'.txt', 'utf8', function (err,data) {
                  if (err) {
                    return console.log(err);
                  }
                  console.log(data);
                  var options = {
                      mode: 'text',
                      args: [req.session.user.username,S(data).between('', '.').s]
                  };

                  PythonShell.run('checkerv1.py',options, function(error, stdout, stderr) {
                       if (error) {
                        return console.log(error);
                      }else{
                        console.log('phani-----------------------------------------------------------');
                      }
                  });

                  });             
              res.sendFile(__dirname + '/public/dashboard_
			   
			   Option.html');
        	  }

        	setTimeout(function1, 3000);	
        }
      });
    }else{
      res.redirect('/login');
    }
      }else{
        res.redirect('/admin_dashboard');
      }
});

app.post('/download', function(req, res) {

 
  console.log("came to post download");

  fs.readFile(__dirname + '/uploaded_files/'+req.session.user.username+'/'+req.session.user.username +'.txt', 'utf8', function (err,data) {
         if (err) {
         return console.log(err);
      }
      console.log(data);
      console.log(S(data).between('', '.').s )
      console.log('copied----');
      res.download(__dirname+'/uploaded_files/'+req.session.user.username+'/'+S(data).between('', '.').s +'/Report.txt');
  }); 

});

app.post('/download_2', function(req, res) {
 
  console.log("came to post download");
  fs.readFile(__dirname + '/uploaded_files/'+req.session.user.username+'/'+req.session.user.username +'.txt', 'utf8', function (err,data) {
         if (err) {
         return console.log(err);
      }
      console.log(data);
      console.log(S(data).between('', '.').s )
      console.log('copied----');
      res.download(__dirname+'/uploaded_files/'+req.session.user.username+'/'+S(data).between('', '.').s +'/scores.csv');
  }); 

});

app.post('/download_3', function(req, res) {
 
  console.log("came to post download");
  fs.readFile(__dirname + '/uploaded_files/'+req.session.user.username+'/'+req.session.user.username +'.txt', 'utf8', function (err,data) {
         if (err) {
         return console.log(err);
      }
      console.log(data);
      console.log(S(data).between('', '.').s )
      console.log('copied----');
      res.download(__dirname+'/uploaded_files/'+req.session.user.username+'/'+S(data).between('', '.').s +'/Plag_Report.txt');
  }); 

});

app.post('/admin_loggingin',function(req,res){

	var username = req.body.username;
	Admin.findOne({username: req.body.username},function(err,admin){
		if(!admin){

			res.sendFile(path.join(__dirname+'/public/admin_login_incorrect.html'));
		}else{
			if(req.body.password === admin.password){
				req.session.admin = admin;
				res.redirect('/admin_dashboard')

			}else{
				res.sendFile(path.join(__dirname+'/public/admin_login_incorrect.html'));

			}
		}
	});
});




app.post('/loggingin',function (req,res) {
  var username = req.body.username;

  User.findOne({username: req.body.username},function (err,user) {
    if(!user){
      res.sendFile(path.join(__dirname+'/public/login_incorrect.html'));
    }else{
      if(req.body.password === user.password){
        req.session.user = user;
        res.redirect('/dashboard');
      }else{
        res.sendFile(path.join(__dirname+'/public/login_incorrect.html'));
      }
    }
  });
});


app.post('/signingup',function (req,res) {
  var username = req.body.username;
  var password = req.body.password;
  var firstname = req.body.firstname;
  var lastname = req.body.lastname;
  var user = new User();

  user.username = username;
  user.password = password;
  user.firstname = firstname;
  user.lastname = lastname;

  user.save(function (err,savedObject) {
    if(err){
      console.log(err);
      res.sendFile(path.join(__dirname+'/public/signup_incorrect.html'));
    }else{
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
      res.send('not able to remove !! may be no user');
    }else {
      res.send('successfully removed');
    }
  });
});



app.post('/setting_new_password',function (req,res) {
  var username = req.body.username;
  var password = req.body.password;
  var confirm_password = req.body.confirm_password;

  if(password != confirm_password){
    res.sendFile(path.join(__dirname+'/public/forgot_password_incorrect_username_or_password.html'));
  }else {


    User.findOne({username: username},function (err,foundObject) {
      if(err){
        console.log(err);
        res.status(500).send();
      }else {

        if(!foundObject){
          res.sendFile(path.join(__dirname+'/public/forgot_password_incorrect_username.html'));
        }else {
          if(req.body.password){
            foundObject.password = password;
          }

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


app.listen(3000, function (err) {
  if(err){
    console.log('port may be in use : bind exception')
  }else{
    console.log('Example aapp listening on port 3000!');
  }
});
