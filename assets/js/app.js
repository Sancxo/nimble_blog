// If you want to use Phoenix channels, run `mix help phx.gen.channel`
// to get started and then uncomment the line below.
// import "./user_socket.js"

// You can include dependencies in two ways.
//
// The simplest option is to put them in assets/vendor and
// import them using relative paths:
//
//     import "../vendor/some-package.js"
//
// Alternatively, you can `npm install some-package --prefix assets` and import
// them using a path starting with the package name:
//
//     import "some-package"
//

// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import "phoenix_html"
// Establish Phoenix Socket and LiveView configuration.
import { Socket } from "phoenix"
import { LiveSocket } from "phoenix_live_view"
import topbar from "../vendor/topbar"

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
let liveSocket = new LiveSocket("/live", Socket, { params: { _csrf_token: csrfToken } })

// Show progress bar on live navigation and form submits
topbar.config({ barColors: { 0: "#29d" }, shadowColor: "rgba(0, 0, 0, .3)" })
window.addEventListener("phx:page-loading-start", _info => topbar.show(300))
window.addEventListener("phx:page-loading-stop", _info => topbar.hide())

// connect if there are any LiveViews on the page
liveSocket.connect()

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket

// Script to make Earmark's Markdown links to target _blank with noreferrer :
const blogPostLinks = document.querySelectorAll("article.post div.post-body a");
for (let link = 0; link < blogPostLinks.length; link++) {
  blogPostLinks[link].setAttribute("rel", "noreferrer");
  blogPostLinks[link].setAttribute("target", "_blank");
}

// Script to display the go_up_arrow component to display only when we scroll down :
const goUpArrow = document.querySelector('#go-up-arrow');
let timeout; // Pointer so we can clean the setTimeout

goUpArrow.style.display = 'none';

function displayArrow() {
  const scrollPos = window.scrollY;

  goUpArrow.style.display = scrollPos >= 100 ? "block" : "none";
  timeout = setTimeout(() => {
    if (
      scrollPos === window.scrollY &&
      (scrollPos + window.innerHeight) < document.body.scrollHeight &&
      !goUpArrow.matches(':hover')) {
      goUpArrow.style.display = "none"
    }
  }, 2000);
}

goUpArrow.addEventListener('mouseout', _ => displayArrow());
window.addEventListener('scroll', _ => displayArrow());

// cleaning functions
goUpArrow.removeEventListener('mouseout', _ => displayArrow());
window.removeEventListener('scroll', _ => displayArrow());
