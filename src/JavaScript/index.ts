const { Elm } = require("../Main.elm");
import "./load_stylesheet";

let elmApp = Elm.Main.init({
  node: document.getElementById("root"),
  flags: JSON.parse(localStorage.getItem("storage")),
});

elmApp.ports.save.subscribe((storage) => {
  localStorage.setItem("storage", JSON.stringify(storage));
  elmApp.ports.load.send(storage);
});
