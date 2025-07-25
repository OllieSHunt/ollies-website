# Project Layout
`./css`, `./html`, and `./js` contain css files, HTML files, and JavaScript files respectively.

`./html-components` contains reusable pieces of HTML that can be imported into other files using server side includes (SSI). For example, adding `<!--#include file="html-components/menu-bar.shtml" -->` in the `<body>` section of `index.shtml` will include a header bar. The same header bar can then be reused in other `.shtml` files.

> [!IMPORTANT]
> Server side includes will not work if you just open a HTML file in a browser. e.g. `firefox index.shtml`.
>
> Instead you must use a server that supports server side includes (like [Nginx](https://nginx.org/en/)) to serve the website on localhost.
>
> See also: `./nginx-dev-setup.sh`
