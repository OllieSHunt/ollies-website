// This code creates an intersection observer to detect when the nav bar
// bar scrolls down. The nav bar will then change its style based of this
// information.
//
// Code in this file is a modified version of: https://stackoverflow.com/a/39575616

const navBar = document.getElementsByTagName("nav")[0];
const navBarAnchor = document.getElementById("nav-bar-anchor");

function updateNavBarClasses(entries) {
  const [entry] = entries;
  if (!entry.isIntersecting) {
    navBar.classList.add("nav-bar-moving");
    navBar.classList.remove("nav-bar-docked");
  } else {
    navBar.classList.add("nav-bar-docked");
    navBar.classList.remove("nav-bar-moving");
  }
}

// Detect when the nav bar anchor goes off the screen
const navBarAnchorObserver = new IntersectionObserver(updateNavBarClasses, {
  root: null,
  threshold: 0,
});

navBarAnchorObserver.observe(navBarAnchor);
