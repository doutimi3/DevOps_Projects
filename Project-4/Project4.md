# __Deploying a MEAN Stack on AWS__

In this project, I will detail how to develop and deploy a MEAN stack on AWS. I will deploy a simple web application with an ExpressJS backend, a MongoDB database layer, and an AngularJS frontend. A user would interact with the AngularJS UI components at the application front end residing in the browser. This frontend is served by the application backend, which is on an Ubuntu server on AWS, through ExpressJS running on top of NodeJS. Each interaction that results in a data update request is routed to the NodeJS-based Express server, which retrieves data from the MongoDB database as needed and provides it to the application’s frontend, where it is shown to the user.

![](https://miro.medium.com/v2/resize:fit:1400/format:webp/1*DdVSh5onFyxnH3l2OvKYXA.png)

__Objectives__

1. To gain a hands-on experience in Linux server administration.
1. Setting up a robust and scalable web server infrastructure
1. Deploy a simple book listing application that creates book name, author, ISBN, etc.
1. Create a MongoDB database that communicates with this book listing application and stores books list.

__Prerequisites__

1. An AWS account with an Admin user created with full admin permissions.
1. Create a key pair and a security group
1. Basic knowledge of AWS services and AWS CLI
1. Basic knowledge of Linux
1. Basic knowledge of how to create an EC2 instance.
1. Basic SSH knowledge
1. Basic knowledge of Database management Systems and the difference between Relational and Non-relational databases.

__Step 1: Launch a Virtual Server with Ubuntu Server OS__

Create a user data script install packages that will be required for this project.
```BASH
#! usr/bin/bash

sudo apt update
sudo apt upgrade
# Add certificates
sudo apt -y install curl dirmngr apt-transport-https lsb-release ca-certificates

# Sets up the Node.js package repository for version 12.x on a Debian-based Linux distribution.
curl -sL https://deb.nodesource.com/setup_14.x | sudo -E bash -

# Install NodeJS
sudo apt install -y nodejs

# Install Netstat utility to display network connections (Optional)
sudo apt-get update && sudo apt-get install net-tools


# Install mongodb
# downloads and adds a public key to the system's list of trusted keys, which is used to verify \
# the authenticity of packages during installation or upgrade in a Debian-based Linux distribution.
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 0C49F3730359A14518585931BC711F9BA15703C6
# Adds a new entry to the sources.list.d directory for the MongoDB package repository. 
echo "deb [ arch=amd64 ] https://repo.mongodb.org/apt/ubuntu trusty/mongodb-org/3.4 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-3.4.list
Install MongoDB package
sudo apt install -y mongodb

# Start mongodb server
sudo service mongodb start
# Verify mongodb server is running
sudo systemctl status mongodb

# Install npm package manager
sudo apt install -y npm

# Install body-parser package
sudo npm install body-parser
```

Create a security group for this project
```SHELL
# Create security group
aws ec2 create-security-group --group-name meanstackSG \
        --description "Security group for Mean Stack project" \
        --vpc-id <Vpc ID> \
        --tag-specifications 'ResourceType=security-group,Tags=[{Key=Name,Value=meanstackSG}]'
```

Allow ssh connection via Port 22 to enable SSH into this remote server:
```SHELL
aws ec2 authorize-security-group-ingress --group-id <Security Group ID> \
                                        --protocol tcp \
                                        --port 22 \
                                        --cidr 0.0.0.0/0
```
Launch an Ubuntu server on AWS for this project
```SHELL
aws ec2 run-instances --image-id <image id>\
        --count 1 \
        --instance-type t2.micro \
        --key-name <KeyPair>\
        --security-group-ids <Security Group Id> \
        --subnet-id <Subnet Id> \
        --user-data file://Path/userdata.sh \
        --block-device-mappings "[{\"DeviceName\":\"/dev/sdf\",\"Ebs\":{\"VolumeSize\":80,\"DeleteOnTermination\":false}}]" \
        --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=MEAN-Stack}]' 'ResourceType=volume,Tags=[{Key=Name,Value=MEAN-Stack-disk}]'
```
Connect to Instance
I will connect to this using ssh client via port 22. This is done using the following block of code:

```SHELL
ssh -i keypair.pem ubuntu@<public Ip Address>
```

The app will be listening at Port 3300 so we need to modify the security group to allow HTTP connection via Port 3300.

```SHELL
aws ec2 authorize-security-group-ingress \
    --group-id "<Security Group ID>" \
    --tag-specifications 'ResourceType=security-group-rule,Tags=[{Key=Name,Value=MEAN-Stack}]' \
    --ip-permissions IpProtocol=tcp,FromPort=3300,ToPort=3300,IpRanges="[{CidrIp=0.0.0.0/0}]" 
```

__Step 2: Set up the Project__

We will be creating a directory called “books” to contain files for this project and change to this directory. The project will be initialized in this directory to create the package.json file and a file called “server.js” will be created in this directory.

```SHELL
# Create project directory
mkdir Books && cd Books

# Initialize project
npm init --yes

#Create server.js file
touch server.js
```
Copy and paste the below web server code below into the server.js file.

```SHELL
var express = require('express');
var bodyParser = require('body-parser');
var app = express();
app.use(express.static(__dirname + '/public'));
app.use(bodyParser.json());
require('./apps/routes')(app);
app.set('port', 3300);
app.listen(app.get('port'), function() {
    console.log('Server up: http://localhost:' + app.get('port'));
});
```

__Step 3: Install Express and set up routes to the server__

We will use Express to pass book information to and from our MongoDB database. We will use Mongoose to establish a schema for the database to store data of our book register.

We will install Mongoose and create a new directory called “apps” and create a new file called “route.js” inside this directory.
```SHELL
# Install express mongoose
sudo npm install express mongoose
# Make app directory and change to this directory
mkdir apps && cd apps
# Create route.js file
touch routes.js
```
Copy and paste the code below into routes.js
```javascript
var Book = require('./models/book');
module.exports = function(app) {
  app.get('/book', function(req, res) {
    Book.find({}, function(err, result) {
      if ( err ) throw err;
      res.json(result);
    });
  }); 
  app.post('/book', function(req, res) {
    var book = new Book( {
      name:req.body.name,
      isbn:req.body.isbn,
      author:req.body.author,
      pages:req.body.pages
    });
    book.save(function(err, result) {
      if ( err ) throw err;
      res.json( {
        message:"Successfully added book",
        book:result
      });
    });
  });
  app.delete("/book/:isbn", function(req, res) {
    Book.findOneAndRemove(req.query, function(err, result) {
      if ( err ) throw err;
      res.json( {
        message: "Successfully deleted the book",
        book: result
      });
    });
  });
  var path = require('path');
  app.get('*', function(req, res) {
    res.sendfile(path.join(__dirname + '/public', 'index.html'));
  });
};
```

Create a new directory called “models” inside the apps directory and create a file called “book.js” and add the below code into this file.

```javascript
var mongoose = require('mongoose');
var dbHost = 'mongodb://localhost:27017/test';
mongoose.connect(dbHost);
mongoose.connection;
mongoose.set('debug', true);
var bookSchema = mongoose.Schema( {
  name: String,
  isbn: {type: String, index: true},
  author: String,
  pages: Number
});
var Book = mongoose.model('Book', bookSchema);
module.exports = mongoose.model('Book', bookSchema);
```

__Step 4: Access the route with AngularJS__

In this project, I use AngularJS to connect our web page with Express and perform actions on our book register.

Change back to the Books directory and create a new directory called “public” to contain the frontend codes. Create a new file called “script.js” inside this directory and copy the below code into this file:

```javascript
var app = angular.module('myApp', []);
app.controller('myCtrl', function($scope, $http) {
  $http( {
    method: 'GET',
    url: '/book'
  }).then(function successCallback(response) {
    $scope.books = response.data;
  }, function errorCallback(response) {
    console.log('Error: ' + response);
  });
  $scope.del_book = function(book) {
    $http( {
      method: 'DELETE',
      url: '/book/:isbn',
      params: {'isbn': book.isbn}
    }).then(function successCallback(response) {
      console.log(response);
    }, function errorCallback(response) {
      console.log('Error: ' + response);
    });
  };
  $scope.add_book = function() {
    var body = '{ "name": "' + $scope.Name + 
    '", "isbn": "' + $scope.Isbn +
    '", "author": "' + $scope.Author + 
    '", "pages": "' + $scope.Pages + '" }';
    $http({
      method: 'POST',
      url: '/book',
      data: body
    }).then(function successCallback(response) {
      console.log(response);
    }, function errorCallback(response) {
      console.log('Error: ' + response);
    });
  };
});
```

Still in the “public” directory, create a new file called “index.html” and paste the below code into this file:

```html
<!doctype html>
<html ng-app="myApp" ng-controller="myCtrl">
  <head>
    <script src="https://ajax.googleapis.com/ajax/libs/angularjs/1.6.4/angular.min.js"></script>
    <script src="script.js"></script>
  </head>
  <body>
    <div>
      <table>
        <tr>
          <td>Name:</td>
          <td><input type="text" ng-model="Name"></td>
        </tr>
        <tr>
          <td>Isbn:</td>
          <td><input type="text" ng-model="Isbn"></td>
        </tr>
        <tr>
          <td>Author:</td>
          <td><input type="text" ng-model="Author"></td>
        </tr>
        <tr>
          <td>Pages:</td>
          <td><input type="number" ng-model="Pages"></td>
        </tr>
      </table>
      <button ng-click="add_book()">Add</button>
    </div>
    <hr>
    <div>
      <table>
        <tr>
          <th>Name</th>
          <th>Isbn</th>
          <th>Author</th>
          <th>Pages</th>

        </tr>
        <tr ng-repeat="book in books">
          <td>{{book.name}}</td>
          <td>{{book.isbn}}</td>
          <td>{{book.author}}</td>
          <td>{{book.pages}}</td>

          <td><input type="button" value="Delete" data-ng-click="del_book(book)"></td>
        </tr>
      </table>
    </div>
  </body>
</html>
```

Change to the “book” directory and start the app using the below command:
```SHELL
node server.js
```
This will start the app to enable us to connect to it via the web browser using HTTP protocol on port 3300.
![](https://miro.medium.com/v2/resize:fit:918/format:webp/1*nMAgxzGbGq1Pe2OEElSKEg.png)

__Conclusion__

We have successfully written a MEAN stack composed of an ExpressJS backend, and a MongoDB database that communicates with an Angular.js frontend.


