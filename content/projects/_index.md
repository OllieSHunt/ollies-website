+++
# Currently, this section is a bit odd.
#
# Its pages are not meant to be actually viewed. Instead, they are all combined
# into one main section page. Because of this, the page_template is just a
# redirect to the appropriate section of the main projects page. This redirect
# is necessary because when these project sections come up in search results and
# clicking on that search result will take you to the child page and not the
# projects section.
#
# Also, I have created a custom sitemap that excludes this section's child pages
# from it. I did this so as not to confuse search engines with random
# unnecessary stuff.

title = "Projects"
sort_by = "weight"
template = "projects-list.html"
page_template = "projects-list-redirect.html"
+++
