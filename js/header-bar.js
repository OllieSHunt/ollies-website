// This code creates an intersection observer to detect when the nav bar
// bar scrolls down. The nav bar will then change its style based of this
// information.
//
// Code in this file is a modified version of: https://stackoverflow.com/a/39575616

const navBar = document.getElementById("header-bar");
const navBarAnchor = document.getElementById("header-bar-anchor");

function updateNavBarClasses(entries) {
  const [entry] = entries;
  if (!entry.isIntersecting) {
    navBar.classList.add("header-bar-moving");
    navBar.classList.remove("header-bar-docked");
  } else {
    navBar.classList.add("header-bar-docked");
    navBar.classList.remove("header-bar-moving");
  }
}

// Detect when the nav bar anchor goes off the screen
const navBarAnchorObserver = new IntersectionObserver(updateNavBarClasses, {
  root: null,
  threshold: 0,
});

navBarAnchorObserver.observe(navBarAnchor);
