# Project Layout
`./css`, `./html`, and `./js` contain css files, HTML files, and JavaScript files respectively.

`./html-components` contains reusable pieces of HTML that can be imported into other files using server side includes (SSI). For example, adding `<!--#include file="html-components/menu-bar.shtml" -->` in the `<body>` section of `index.shtml` will include a header bar. The same header bar can then be reused in other `.shtml` files.

> [!IMPORTANT]
> Server side includes will not work if you just open a HTML file in a browser. e.g. `firefox index.shtml`.
>
> Instead you must use a server that supports server side includes (like [Nginx](https://nginx.org/en/)) to serve the website on localhost.
>
> See also: `./dev-scripts/nginx-dev-setup.sh`

# Design and Development

## Scaling
Although this project does not use Bootstrap, I aim to use the same "scaling increments" (idk what they are called).

https://getbootstrap.com/docs/4.0/layout/grid/#grid-options
- >=1200px - default
- >=992px
- >=768px
- >=576px
- < 576px

Here are the corresponding media queries for these sizes:
```css
@media (max-width: 1200px) { /* 992px-1200px */ }
@media (max-width: 992px) { /* 768px-992px */ }
@media (max-width: 768px) { /* 556px-768px */ }
@media (max-width: 576px) { /* 0px-556px */ }
```
