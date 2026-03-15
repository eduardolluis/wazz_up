const express = require("express");
let http = require("http");

const app = express();
const port = process.env.PORT || 5000;
let server = http.createServer(app);
let io = require("socket.io")(server);

app.use(express.json());

let clients = {};

io.on("connection", (socket) => {
  console.log("a user connected");
  console.log(socket.id, "has joined ");

  socket.on("signin", (id) => {
    console.log(id);
    clients[id] = socket;
    console.log(clients);
  });

  socket.on("message", (msg) => {
    console.log(msg);
    let targetId = msg.targetId;
    if (clients[targetId]) clients[targetId].emit("message", msg);
  });
});

app.get("/", (req, res) => {
  res.send("Server is running");
});

app.get("/check", (req, res) => {
  res.json("Your app is working fine");
});

server.listen(port, "0.0.0.0", () => {
  console.log("server started on port " + port);
});
