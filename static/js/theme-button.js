// This code changes the theme of the website when the "theme button" is
// pressed.
//
// Useful resource on how to do this:
// https://lukelowrey.com/css-variable-theme-switcher/

// On click handler for theme changing button
document.getElementById("theme-button").onclick = function () {
  var currentTheme = document.documentElement.getAttribute("data-theme");

  // If dark set to light, if light set to dark
  if (currentTheme === "dark") {
    setTheme("light", true);
  } else {
    setTheme("dark", true);
  }
};

// If there is a saved theme, use that. Else, check what their preferred theme is.
const savedTheme =
  localStorage.getItem("theme") ||
  (window.matchMedia("(prefers-color-scheme: dark)").matches
    ? "dark"
    : "light");

if (savedTheme) setTheme(savedTheme);

/**
 * This will change the theme to ether light or dark mode.
 *
 * @param {string} theme Ether "light" or "dark"
 * @param {boolean} shouldSave Whether the new theme should be saved using local storage
 */
function setTheme(theme, shouldSave = false) {
  // Check parameter is "light" or "dark"
  if (theme !== "light" && theme !== "dark") {
    throw new Error('Theme should be ether "light" or "dark".');
  }

  const themeIconButton = document.getElementById("theme-button-icon");

  // Work out which theme this is not
  otherTheme = theme === "dark" ? "light" : "dark";

  console.log(
    "Changing theme to " +
      theme +
      " and" +
      (shouldSave ? " " : " NOT ") +
      "saving to local storage.",
  );

  // Change button icon
  themeIconButton.classList.add(otherTheme + "-mode-icon");
  themeIconButton.classList.remove(theme + "-mode-icon");

  // Update theme and save it for future visits
  document.documentElement.setAttribute("data-theme", theme);
  if (shouldSave) localStorage.setItem("theme", theme);
}
