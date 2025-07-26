// This code creates an intersection observer to detect when the navigation
// bar scrolls down. The nav bar will then change its style based of this
// information.

const navBar = document.getElementById("nav-bar");
const navBarAnchor = document.getElementById("nav-bar-anchor");

function updateNavColor(entries) {
  const [entry] = entries;
  if (!entry.isIntersecting) {
    navBar.classList.add("nav-moving");
    navBar.classList.remove("nav-docked");
  } else {
    navBar.classList.add("nav-docked");
    navBar.classList.remove("nav-moving");
  }
}

const navBarAnchorObserver = new IntersectionObserver(updateNavColor, {
  root: null,
  threshold: 0,
});

navBarAnchorObserver.observe(navBarAnchor);
