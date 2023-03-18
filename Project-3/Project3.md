# Deploying a MERN Stack on AWS
In this project, I will detail how to develop and deploy a MERN stack on AWS. I will deploy a simple web application with an ExpressJS backend, a MongoDB database layer, and a ReactJS frontend. A user would interact with the ReactJS UI components at the application frontend residing in the browser. This frontend is served by the application backend, which is on an Ubuntu server on AWS, through ExpressJS running on top of NodeJS. Each interaction that results in a data update request is routed to the NodeJS-based Express server, which retrieves data from the MongoDB database as needed and provides it to the application’s frontend, where it is shown to the user.

![MERN Stack](https://miro.medium.com/v2/resize:fit:1400/format:webp/1*XMS0Z51MwjV8gRjGfEkg5w.png)

__Objectives__

1. To gain a hands-on experience in Linux server administration
1. Setting up a robust and scalable web server infrastructure
1. Deploy a simple To-DO application that creates To-Do lists.
1. Create a MongoDB database that communicates with this To-Do application and stores to-do list.
1. Get familiar with RESTful API

__Prerequisites__

1. You have an AWS account set up and have an Admin user created with full admin permissions. Click the link: [Getting Started on AWS](https://medium.com/@angalabiridortimiariyemaxwell/getting-started-on-aws-cb19990a7575) for a detailed step-by-step guide on how to create an AWS account.
1. Install and configure the AWS CLI.
1. Create a [key pair](https://docs.aws.amazon.com/cli/latest/userguide/cli-services-ec2-keypairs.html) and a [security](https://docs.aws.amazon.com/cli/latest/userguide/cli-services-ec2-sg.html) group.
1. Basic knowledge of AWS
1. Basic knowledge of Linux
1. Basic knowledge of how to create an EC2 instance.
1. Basic SSH knowledge
1. Basic knowledge of Database management Systems and the difference between Relational and Non-relational databases.
1. Basic knowledge of CSS and HTML.

__Step 1: Launch a Virtual Server with Ubuntu Server OS__

Follow the steps detailed in [EC2 Instance using the Console and AWS CLI](https://medium.com/@angalabiridortimiariyemaxwell/launching-an-ec2-instance-using-the-console-and-aws-cli-e1a33e43e5d5) to launch an EC2 instance of the t2.micro family with an Ubuntu server 20.04 LTS (HVM) image and connect to this instance via ssh. This was done using the below block of code:
```SHELL
aws ec2 run-instances --image-id ami-038d76c4d28805c09 \
        --count 1 \
        --instance-type t2.micro \
        --key-name keypair \
        --security-group-ids sg-0d2f6628dcd408cb4 \
        --subnet-id subnet-0efc3d163d7ae14b4 \
        --block-device-mappings "[{\"DeviceName\":\"/dev/sdf\",\"Ebs\":{\"VolumeSize\":30,\"DeleteOnTermination\":false}}]" \
        --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=MERN-Stack}]' 'ResourceType=volume,Tags=[{Key=Name,Value=MERN-Stack-disk}]'
```
Connect to Instance
```
ssh -i keypair.pem ubuntu@35.178.168.50
```
__Step 2: Backend Configuration__
To configure the backend, we need to install NodeJS, npm, and create a "Todo" directory to contain all files for this project.
```SHELL
# Update ubuntu
sudo apt update
# Upgrade ubuntu
sudo apt upgrade -y

# Adds the NodeSource repository to your system's list of package sources and installs the latest stable version of Node.js
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -

# Install Node.js and npm on the server
sudo apt-get install -y nodejs
# If needed, install npm. Firstly, check if npm is already installed.
sudo apt install npm -y
# Verify the node installation
node -v
# Verify the npm installation
npm -v
# Create a new directory for your To-Do project
mkdir Todo
# change pwd to this directory
cd Todo
# Initialize the project to create package.json file
npm init
```
After running the npm init command, press Enter several times to accept the default values, then accept to write out the package.json file by typing yes.

![](https://miro.medium.com/v2/resize:fit:1278/format:webp/1*dnoQ9LZeKt6-vFe4bsOCYQ.png)

__Install ExpressJS__

I will be installing ExpressJS using the npm package manager and creating the Routes directory.
```SHELL
# Install ExpressJS using npm
npm install express
# Create index.js file
touch index.js
# Install dotenv to load environment variables
npm install dotenv
# Edit index.js using vim 
vim index.js
# Add the following block of code:
const express = require('express');
require('dotenv').config();

const app = express();

const port = process.env.PORT || 5000;

app.use((req, res, next) => {
res.header("Access-Control-Allow-Origin", "\*");
res.header("Access-Control-Allow-Headers", "Origin, X-Requested-With, Content-Type, Accept");
next();
});

app.use((req, res, next) => {
res.send('Welcome to Express');
});

app.listen(port, () => {
console.log('Server running on port ${port}')
});

# Start server to see if it works
node index.js
```
If everything goes well, after starting the server, you should see “Server running on port 5000” in your terminal.

![](https://miro.medium.com/v2/resize:fit:1064/format:webp/1*x6cvB0xciEyajaHSam_C-Q.png)

Open Port 5000 in the EC2 instance Security Group
```SHELL
aws ec2 authorize-security-group-ingress \
    --group-id "sg-0d2f6628dcd408cb4" \
    --tag-specifications 'ResourceType=security-group-rule,Tags=[{Key=Name,Value=MernStack-SG}]' \
    --ip-permissions IpProtocol=tcp,FromPort=5000,ToPort=5000,IpRanges="[{CidrIp=0.0.0.0/0}]" \
    IpProtocol=tcp,FromPort=80,ToPort=80,IpRanges="[{CidrIp=0.0.0.0/0}]"
```
![](https://miro.medium.com/v2/resize:fit:1400/format:webp/1*bJx_KwvDsl9H0ZbR-e8dhA.png)

Access the app via http protocol on your browser: http://35.178.168.50:5000/

![](https://miro.medium.com/v2/resize:fit:1400/format:webp/1*R7i15336KHNdcHOMO5wpIg.png)

__Configure Routes__
This ToDo application needs to be able to perform the following actions:

Create a new task
Display a list of all tasks
Delete a completed task
Each action would be associated with some particular endpoint and use different standard [HTTP request methods](https://developer.mozilla.org/en-US/docs/Web/HTTP/Methods): POST, GET, and DELETE.

For each task, we need to create "routes" that will define various endpoints that the Todo application will depend on. So I will create a folder called “routes” and create a new file called “api.js” inside this new folder. This new file, "api.js,” would define three routes for a RESTful API that can handle HTTP GET, POST, and DELETE requests for a resource called "todos."

```SHELL
# Create new directory for routes and change to this directory
mkdir routes
cd routes

# create api.js file
touch api.js

# Edit it using to add the following block of code, then save using "esc":wq
vim api.js

const express = require ('express');
const router = express.Router();

router.get('/todos', (req, res, next) => {

});

router.post('/todos', (req, res, next) => {

});

router.delete('/todos/:id', (req, res, next) => {

})

module.exports = router;
```
__Models__

This Todo app is going to make use of MongoDB which is a NoSQL database so we need to create a model to enable this. We will also use models to define the database schema. We need to install mongoose, which is a Node.js package that makes working with MongoDB easier. This will enable the creation of the schema and models.

```SHELL
# Change to the Todo directory
cd ..

# Install mongoose
npm install mongoose

#Create models directory, and create todo.js file inside this directory
mkdir models && cd models && touch todo.js

# Edit the todo.js file using vim to add the following block of code:
vim todo.js

const mongoose = require('mongoose');
const Schema = mongoose.Schema;

//create schema for todo
const TodoSchema = new Schema({
action: {
type: String,
required: [true, 'The todo text field is required']
}
})

//create model for todo
const Todo = mongoose.model('todo', TodoSchema);

module.exports = Todo;
```
Next, we need to edit the api.js file to add the blow block of code:
```SHELL
const express = require ('express');
const router = express.Router();
const Todo = require('../models/todo');

router.get('/todos', (req, res, next) => {

//this will return all the data, exposing only the id and action field to the client
Todo.find({}, 'action')
.then(data => res.json(data))
.catch(next)
});

router.post('/todos', (req, res, next) => {
if(req.body.action){
Todo.create(req.body)
.then(data => res.json(data))
.catch(next)
}else {
res.json({
error: "The input field is empty"
})
}
});

router.delete('/todos/:id', (req, res, next) => {
Todo.findOneAndDelete({"_id": req.params.id})
.then(data => res.json(data))
.catch(next)
})

module.exports = router;
```
Overall, this code defines the routes for handling GET, POST, and DELETE requests for a “todo” resource in an Express app and interacts with the “todo” collection in a MongoDB database using the Mongoose library.


__MongoDB Database__

We’ll need a database to store our data. We will make use of mLab for this. mLab offers MongoDB database as a service (DBaaS), so to make things easier, sign up for a free shared clusters account, which is appropriate for our use case. Selecting Amazon as the cloud provider and a region near you.

![](https://miro.medium.com/v2/resize:fit:1400/format:webp/1*NeArOUm53m90p8tKArgM4A.png)

Create a new user, enter username and password

![](https://miro.medium.com/v2/resize:fit:1400/format:webp/1*XbHXXsIWsBaAycN4Vhu8uw.png)

Add your system IP to both the cloud and local environment, then finish and close.

![](https://miro.medium.com/v2/resize:fit:1400/format:webp/1*ldnUOqvSOgLxEVEsNymuTg.png)

Allow access to the MongoDB database from anywhere (Not secure, but it is ideal for testing)

![](https://miro.medium.com/v2/resize:fit:1400/format:webp/1*eH35VrvmT1hBpL3guibOjQ.png)

Click on “Browse collections” to Create a MongoDB database and collection inside mLab

![](https://miro.medium.com/v2/resize:fit:1400/format:webp/1*WDccCoIRMlXPFQBGQfCbAQ.png)

![](https://miro.medium.com/v2/resize:fit:1400/format:webp/1*ddTDeA4DBebNNxpotYwPiQ.png)

![](https://miro.medium.com/v2/resize:fit:1134/format:webp/1*J6fBSZU5zl9NplQcR07Wtw.png)

Recall, in the index.js file, we specified process.env to access environment variables, but we have not create the env file. We will create this file in “Todo” directory and name it .env. We will then add the MongoDB connection string to this file.

Click on “Connect” select “Connect your application” and select Node.js driver from the Driver drop-down to get your connection string. Ensure to update "username", "password", "network-address" and "database" according to your setup.

![](https://miro.medium.com/v2/resize:fit:1400/format:webp/1*ErowEuVNMrPg1wbcm4RhQw.png)

Create a file in the Todo directort call .env and add the below block of code:
```SHELL
DB = 'mongodb+srv://<username>:<password>@cluster0.hidix6w.mongodb.net/Todo?retryWrites=true&w=majority'
```
Now we need to modify the index.js file in /home/ubuntu/Todo directory to use of .env so that Node.js can connect to the database. We will do this by deleting the existing content in the file and updating it with the entire code below.

```SHELL
const express = require('express');
const bodyParser = require('body-parser');
const mongoose = require('mongoose');
const routes = require('./routes/api');
const path = require('path');
require('dotenv').config();

const app = express();

const port = process.env.PORT || 5000;

//connect to the database
mongoose.connect(process.env.DB, { useNewUrlParser: true, useUnifiedTopology: true })
.then(() => console.log(`Database connected successfully`))
.catch(err => console.log(err));

//since mongoose promise is depreciated, we overide it with node's promise
mongoose.Promise = global.Promise;

app.use((req, res, next) => {
res.header("Access-Control-Allow-Origin", "\*");
res.header("Access-Control-Allow-Headers", "Origin, X-Requested-With, Content-Type, Accept");
next();
});

app.use(bodyParser.json());

app.use('/api', routes);

app.use((err, req, res, next) => {
console.log(err);
next();
});

app.listen(port, () => {
console.log(`Server running on port ${port}`)
});
```
Start your server using the command:
```SHELL
node index.js
```
If the setup is correct, you will receive the output shown in the screenshot below which indicates that the application backend is completely set up:

![](https://miro.medium.com/v2/resize:fit:930/format:webp/1*iTwmcFSAmcojL_S2fft6Jw.png)

This implies we have successfully written the backend code of the Todo application, configured the MongoDB, and connected the Todo application with the MongoDB. Next, we will test the application without a frontend using a RESTful API.

__Testing Backend Code without Frontend using RESTful API__
I will be using Postman for this project. First, I need to install Postman. Click on the link to download and [install Postman](https://www.postman.com/downloads/) on your machine and create a free account. To learn more about using Postman for [CRUD Operations](https://en.wikipedia.org/wiki/Create,_read,_update_and_delete) click [HERE](https://www.youtube.com/watch?v=FjgYtQK_zLE).

In Postman, I will create a POST request to the API http://35.178.168.50:5000/api/todos. Set the header key to “Content-Type” and the value as “application/json”

![](https://miro.medium.com/v2/resize:fit:1400/format:webp/1*QqjuQse38uyKZhjifRIl0g.png)

Create a post request with the below payload and click on "Send." This will output the id of the request shown in the bottom pane:

![](https://miro.medium.com/v2/resize:fit:1400/format:webp/1*SlvSob6uIHOOUNJwfGvftQ.png)

Create a GET request to your API on the same API to retrieves all existing records from the Todo application. The backend of our application will request these records from the database and send them back a response.

![](https://miro.medium.com/v2/resize:fit:1400/format:webp/1*iVU62Zif9MLvVkGw25EV8Q.png)

These records are now loaded into the MongoDB database

![](https://miro.medium.com/v2/resize:fit:1400/format:webp/1*x53rySqIuxITPxRh3mWohA.png)

The backend and database have been successfully created, now I will move on to creating the frontend.

__Step 2: Create Frontend__
To start out with the frontend of the Todo app, we will use the create-react-app command to scaffold our app.

Change to the Todo app root directory and run the “create-react-app” command. This will create a new folder in the “Todo” directory called “client” where we will be adding all the react code.

```SHELL
npx create-react-app client
```
__Running a React App__
We need to install the following dependencies before running the react app

1. Install “concurrently”. This can be used to run more than one command simultaneously from the same terminal window.
1. Install “nodemon”. It is used to run and monitor the server, it restarts the server automatically if there is a change in the server code.

```SHELL
# Install concurrently
npm install concurrently --save-dev

# Install nodemon
npm install nodemon --save-dev
```
Open the package.json file in the “Todo” directory and replace the "scripts" section of the code on the below screenshot with the block of code below:

![](https://miro.medium.com/v2/resize:fit:1070/format:webp/1*jtdDWMmBNy9ZKD_8xajcQA.png)

```SHELL
"scripts": {
"start": "node index.js",
"start-watch": "nodemon index.js",
"dev": "concurrently \"npm run start-watch\" \"cd client && npm start\""
},
```
__Configure Proxy in package.json__

1. Change directory to “client”
1. Open the package.json file
1. Add the key value pair to the package.json file “proxy”: “http://localhost:5000". This is added to make it possible to access the application directly from the browser by simply calling the server URL http:/localhost:5000 rather than always including the entire path like http://localhost:5000/api/todos.
1. cd to the Todo directory and run the npm run dev command to start the application on http://localhost:3000

```SHELL
#Change to client directory
cd client
# Open package.json using vim
vi package.json
# Edit file to add the below line of code:
"proxy": "http://localhost:5000"
# change to Todo directory
/home/ubuntu/Todo/
# Start app
npm run dev
```

package.json file should look like this after adding the proxy key-value pair:
![](https://miro.medium.com/v2/resize:fit:1190/format:webp/1*-FKxiVENb_08Ka-bY4qEIQ.png)

If you get the below output after running npm run dev command then the set up was successfully.

![](https://miro.medium.com/v2/resize:fit:1116/format:webp/1*p6cU3qJSJgQI3kriRmV30w.png)

In order to be able to access the application from the Internet, you have to open TCP port 3000 on EC2 by adding a new security group rule.

```SHELL
aws ec2 authorize-security-group-ingress \
    --group-id "sg-0d2f6628dcd408cb4" \
    --protocol tcp \
    --port 3000 \
    --cidr "0.0.0.0/0"
```
__Creating your React Components__

One benefit of using React is that it uses reusable components and makes code modular. There will be two stateful components and one stateless component in our Todo app.

Run the following command from your Todo directory:
```SHELL
# Change to client directory
cd /home/ubuntu/Todo/client
# change to src directory
cd src
# make components directory
mkdir components
#Change to components directory
cd components
# create three new files inside component directory
touch Input.js ListTodo.js Todo.js
```

Edit Input.js to add the below block of code:

```SHELL
import React, { Component } from 'react';
import axios from 'axios';

class Input extends Component {

state = {
action: ""
}

addTodo = () => {
const task = {action: this.state.action}

    if(task.action && task.action.length > 0){
      axios.post('/api/todos', task)
        .then(res => {
          if(res.data){
            this.props.getTodos();
            this.setState({action: ""})
          }
        })
        .catch(err => console.log(err))
    }else {
      console.log('input field required')
    }

}

handleChange = (e) => {
this.setState({
action: e.target.value
})
}

render() {
let { action } = this.state;
return (
<div>
<input type="text" onChange={this.handleChange} value={action} />
<button onClick={this.addTodo}>add todo</button>
</div>
)
}
}

export default Input
```
To use Axios, a Promise-based HTTP client for the browser and node.js, cd into your client and execute yarn add axios or npm install axios from your terminal.

```SHELL
# Move to client directory
cd /home/ubuntu/Todo/client
# Install Axios
npm install axios
```
Change to the /home/ubuntu/Todo/client/src/components directory and edit the ListTodo.js file to add the below block of code:

```SHELL
import React from 'react';

const ListTodo = ({ todos, deleteTodo }) => {

return (
<ul>
{
todos &&
todos.length > 0 ?
(
todos.map(todo => {
return (
<li key={todo._id} onClick={() => deleteTodo(todo._id)}>{todo.action}</li>
)
})
)
:
(
<li>No todo(s) left</li>
)
}
</ul>
)
}

export default ListTodo
```
Edit the Todo.js file to add the below block of code:

```SHELL
import React, {Component} from 'react';
import axios from 'axios';

import Input from './Input';
import ListTodo from './ListTodo';

class Todo extends Component {

state = {
todos: []
}

componentDidMount(){
this.getTodos();
}

getTodos = () => {
axios.get('/api/todos')
.then(res => {
if(res.data){
this.setState({
todos: res.data
})
}
})
.catch(err => console.log(err))
}

deleteTodo = (id) => {

    axios.delete(`/api/todos/${id}`)
      .then(res => {
        if(res.data){
          this.getTodos()
        }
      })
      .catch(err => console.log(err))

}

render() {
let { todos } = this.state;

    return(
      <div>
        <h1>My Todo(s)</h1>
        <Input getTodos={this.getTodos}/>
        <ListTodo todos={todos} deleteTodo={this.deleteTodo}/>
      </div>
    )

}
}

export default Todo;
```
Change to /home/ubuntu/Todo/client/src/ directory and make changes to the App.js file to delete the React logo. Open up this file, delete all content and add the below block of code:

```SHELL
import React from 'react';

import Todo from './components/Todo';
import './App.css';

const App = () => {
return (
<div className="App">
<Todo />
</div>
);
}

export default App;
```

Next, open the App.css file and paste the below block of code:

```SHELL
.App {
text-align: center;
font-size: calc(10px + 2vmin);
width: 60%;
margin-left: auto;
margin-right: auto;
}

input {
height: 40px;
width: 50%;
border: none;
border-bottom: 2px #101113 solid;
background: none;
font-size: 1.5rem;
color: #787a80;
}

input:focus {
outline: none;
}

button {
width: 25%;
height: 45px;
border: none;
margin-left: 10px;
font-size: 25px;
background: #101113;
border-radius: 5px;
color: #787a80;
cursor: pointer;
}

button:focus {
outline: none;
}

ul {
list-style: none;
text-align: left;
padding: 15px;
background: #171a1f;
border-radius: 5px;
}

li {
padding: 15px;
font-size: 1.5rem;
margin-bottom: 15px;
background: #282c34;
border-radius: 5px;
overflow-wrap: break-word;
cursor: pointer;
}

@media only screen and (min-width: 300px) {
.App {
width: 80%;
}

input {
width: 100%
}

button {
width: 100%;
margin-top: 15px;
margin-left: 0;
}
}

@media only screen and (min-width: 640px) {
.App {
width: 60%;
}

input {
width: 50%;
}

button {
width: 30%;
margin-left: 10px;
margin-top: 0;
}
}
```
Still in the src directory open the index.css and copy and paste the below block of code into this file:

```SHELL
body {
margin: 0;
padding: 0;
font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", "Roboto", "Oxygen",
"Ubuntu", "Cantarell", "Fira Sans", "Droid Sans", "Helvetica Neue",
sans-serif;
-webkit-font-smoothing: antialiased;
-moz-osx-font-smoothing: grayscale;
box-sizing: border-box;
background-color: #282c34;
color: #787a80;
}

code {
font-family: source-code-pro, Menlo, Monaco, Consolas, "Courier New",
monospace;
}
```
Change to the Todo directory and run the npm run dev command to start the app.

```SHELL
npm run dev
```
Assuming no errors occurred throughout the process of storing these data, our To-Do app should be ready and fully functional with the capabilities to create a task, delete a task, and see all of your tasks.

![](https://miro.medium.com/v2/resize:fit:1400/format:webp/1*swgPMF5SZ3CVANKLqrPoXQ.png)

__Conclusion__

We have successfully written a MERN stack composed of an ExpressJS backend, and a MongoDB database that communicates with a React.js frontend.
















