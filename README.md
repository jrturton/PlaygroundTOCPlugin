# PlaygroundTOC

Xcode plugin for creating a TOC and navigation links for multi-page playgrounds. 

Not yet submitted to Alcatraz, but you can install it yourself by building and running the project.

If the main window is editing a `.playground`, then **File** > **Generate Playground TOC** will read the pages and create a formatted list of links to each page. The text is copied to the system clipboard to be pasted wherever you need it. 

The format of the TOC is:

```
/*:
- [Page title](link)
*/
```

Where `Page Title` is taken from the first line of text in the playground with one or more header (`#`) markdown tags. 

To create titled Previous / Next links choose **File** > **Insert Page Previous / Next Links**, which will add or update named links to the previous and next pages (where applicable) and an `x of y` page count indicator to every page in the playground. 