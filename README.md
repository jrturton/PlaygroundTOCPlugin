# PlaygroundTOC

Xcode plugin for creating a TOC for multi-page playgrounds. 

Not yet submitted to Alcatraz, but you can install it yourself by building and running the project.

If the main window is editing a `.playground`, then **File** > **Generate Playground TOC** will read the pages and create a formatted list of links to each page. The text is copied to the system clipboard to be pasted wherever you need it. 

The format of the TOC is:

```
/*:
- [Page title](link)
*/
```

Where `Page Title` is taken from the first line of text in the playground with one or more header (`#`) markdown tags. 