import { Elm } from "./Main.elm";

const stylesLayerOne = import.meta.globEager("./Styles/**/_index.scss");
const stylesLayerTwo = import.meta.globEager("./Styles/**/**/_index.scss");

const app = Elm.Main.init();
