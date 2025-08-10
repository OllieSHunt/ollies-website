+++
title = "Accidentally Reinventing The Static Site Generator"
description = "Making a basic static site generator using Python's `str.replace` method and server side includes (SSI). I also talk about how to use SSI, why it is useful, as well as the benefits of Zola."
date = 2025-08-09
+++

# Accidentally Reinventing The Static Site Generator

## Setting the Scene

So a while ago, I decided to build my own website/blog (your reading it right now!).

The first thing I did after the usual HTML boilerplate was to start work on a navigation bar. The nav bar is, in my opinion, the "core" of any website. Its on every single page and users will keep coming back to it again and again to move around your page.

After a few notebook sketches and indecision, I eventually settled on the following design:

![Initial navigation bar prototype](nav-bar.png)

When you scrolled, it visually changed its style and followed you down the page. Overall, I was quite happy with this design.

But I now had an issue to deal with: when I create new pages, how do I get this navigation bar onto all those new pages? The obvious approach is to just copy-paste the HTML across, but this has some issues. The main one being that if I make changes to the nav bar's design, I then have to go through and update **every** single page on the site with the new code! What if I missed one? Users would notice the inconsistent styling and it would feel jarring and odd.

After some research, I found a better solution: *server side includes*.

## Server Side Includes (SSI)

[According to Wikipedia](https://en.wikipedia.org/wiki/Server_Side_Includes):

> Server Side Includes (SSI) is a simple interpreted server-side scripting
> language used almost exclusively for the World Wide Web.

For my use case, this means that I can have the server dynamically *build* a HTML file before sending it of to be displayed in the users browser.

Here's an example:

```html
<!-- nav-bar.shtml -->

<nav id="nav-bar">
  <!-- Navigation bar code goes here -->
</nav>
```

```html
<!-- index.shtml -->

<!doctype html>
<html lang="en">
  <head>
    <!-- Header goes here -->
  </head>

  <body>
    <!-- Here is the server side include. As you can see,
         it looks very similar to a regular HTML comment -->

    <!--#include file="nav-bar.shtml" -->

    <main>
      <!-- Page's main content goes here -->
    </main>
  </body>
</html>
```

This will cause the server (in my case [Nginx](https://nginx.org/en/))[^1] to copy the continence of `nav-bar.shtml` *into* `index.html` *before* it is sent of to the end users computer to be rendered in their browser.

The benefit of this is that now, whenever I want to make changes to the navigation bar, my updates will be instantly reflected across the whole site with zero effort from me!

> [!NOTE]
> You may also have noticed the file extension `.shtml` instead of `.html`. This
> tells the server to look for server side includes within the file.

After creating the nav bar, I made a theme switching button that would toggle between light and dark modes when you pressed it. This feature also benefited from SSI for the same reasons as the nav bar.

```html
<!-- index.shtml -->
<!-- Boilerplate code omitted -->

<body>
  <!--#include file="nav-bar.shtml" -->
  <!--#include file="theme-button.shtml" -->

  <main>
    <!-- Page's main content goes here -->
  </main>
</body>
```

![Theme switching button in dark mode](theme-button-dark.png)

![Theme switching button in light mode](theme-button-light.png)

## Markdown

With the backbone of the website's code and a few key features out the way, I moved on to thinking about how I would write content for my blog. Writing actual English documents in HTML can be tedious. Balancing opening and closing tags, trying to remember the difference between `<strong>`, `<em>`, `<i>`, and `<b>`, and all the while trying to make coherent sentences that people actually want to read. Not easy.

Enter, [Markdown](https://en.wikipedia.org/wiki/Markdown).

Markdown is the perfect choice here. It enables me write blog posts without having to code at the same time. It also has a plethora of excellent parsers readily available to convert my documents to HTML.

I would want to automate the process of course, so I got to work writing a Python script. The script would read all markdown files from a given directory and then use [Pandoc](https://pandoc.org/) to do the actual conversion. This left me with some nice HTML code ready to be rendered by a browser.

```python
# This function takes a path to a markdown file and returns a
# string of HTML code.
#
# Requires the pandoc binary to be installed in order to work.
def mdToHtml(mdPath: Path) -> str:
    # Use the external pandoc command to perform the conversion
    result = subprocess.run(
        ["pandoc", "-f", "gfm", "-t", "html5", mdPath],
        capture_output=True, text=True
    )

    # Exit if command failed
    if result.returncode != 0:
        sys.exit("ERROR: Markdown to HTML conversion command exited with non-zero exit code.\n\nSTDOUT:\n%s\n\nSTDERR:\n%s" % (result.stdout, result.stderr))

    # Return generated HTML with comment giving credit to pandoc
    return (
        "<!-- HTML generated by [pandoc](https://pandoc.org) from a markdown file -->\n\n" +
        result.stdout
    )
```

Next, I needed a way to put the generated HTML into a template that includes the nav bar, the theme button, and all the boilerplate HTML. Here is the template I made:

```html
<!doctype html>
<html lang="en">
  <head>
    <!-- Meta tags, style sheets, etc... -->
  </head>

  <body>
    <!--#include file="/html-components/nav-bar.shtml" -->
    <!--#include file="/html-components/theme-button.shtml" -->

    <main>
      <!-- ARTICLE CONTENT -->
    </main>
  </body>
</html>
```

Now, in Python I could just use the built in string replace function ([`str.replace`](https://docs.python.org/3/library/stdtypes.html#str.replace)) to search for the `<!-- ARTICLE CONTENT -->` string and replace it with the HTML output by Pandoc.

In case you are curious, the full Python script can be found [here](https://github.com/OllieSHunt/ollies-website/blob/ccc93d9cb187cbb11fb65173553a5e9c274b77c9/dev-scripts/build-blog.py).

## Reinventing The Wheel
So this works. And it works well. Whenever I write a blog article in markdown, I can just re-run the Python script and have it be automatically converted into HTML and inserted into my template. Then Nginx will use server side includes to automatically insert the nav bar and any other needed elements.

But, during my research for alternative markdown parsers to Pandoc, I found a new type of software that I was not previously aware existed: [static site generators](https://en.wikipedia.org/wiki/Static_site_generator).

Here are some excerpts from Wikipedia that explain SSGs very concisely:

> Static site generators (SSGs) are software engines that use text input files
> (such as Markdown, reStructuredText, AsciiDoc and JSON) to generate static web
> pages.

> SSGs typically consist of a template written in HTML with a templating system,
> such as Liquid (Jekyll) or Go template (Hugo). The same structure (typically a
> Git repository) includes content in a plain-text format such as Markdown or
> reStructuredText, or in a structural meta format such as JSON or XML. A single
> plain-text file may correspond to a single web page.

Hang on a second, this almost perfectly describes what I have just spent dozens of hours creating! My templating system just is a combination of SSI and Python's `str.replace` method, and my content is written in Markdown!

I have unintentionally made a very basic, slightly inflexible, static site generator.

## Zola
So, i've made an SSG. Oops. As were here, I may as well make my life easier by doubling down and pivot towards a proper, purpose built static site generator that's better build, has more features, and is generally a lot more robust.

There are [lots](https://github.com/topics/static-site-generator) of excellent sounding options here, but after some thought I picked out [Zola](https://www.getzola.org/) as my favourite. Honestly, the main reason for this was that it is written in Rust. I know this is not the most sensible reason to choose based off of, but there were so many options, I decided to just pick one and Zola is the one I picked.

After spending some time converting my code[^2] over in a separate git branch, I have decided that Zola was definitely the correct choice. Remember that blog post template from earlier? Here is a revised version using Zola:

```html
{% extends "base.html" %}

{% block content %}
<article>
    {{ page.content | safe }}
</article>
{% endblock content %}
```

Much shorter.

And here's a new page that creates a very simple list of all blog posts.

```html
{% extends "base.html" %}

{% block content %}
<h1>{{ section.title }}</h1>
<ul>
    {% for page in section.pages %}
    <li><a href="{{ page.permalink | safe }}">{{ page.title }}</a></li>
    {% endfor %}
</ul>
{% endblock content %}
```

Do you see that? A for loop! That is way out of the scope my little Python script. In fact, in between those curly brackets, Zola essentially allows for a whole other programming language with support for variables, if statements, and of course, loops! This allows for much more power and flexibility going forward with my site and I am definitely glad I decided to switch.

Moral of the story? Don't reinvent the wheel because someone has already done it better.

[^1]: If your using [Nginx](https://nginx.org/en/) like I was, then SSI will be disabled by default, you can use [this configuration file](https://github.com/OllieSHunt/ollies-website/blob/ccc93d9cb187cbb11fb65173553a5e9c274b77c9/dev-scripts/nginx-dev.conf) as an example of how to enable it.

[^2]: In case you want to see it, [here is a link to the last commit](https://github.com/OllieSHunt/ollies-website/tree/ccc93d9cb187cbb11fb65173553a5e9c274b77c9) of of my site that did not use Zola.
