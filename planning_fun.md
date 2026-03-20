The primary use I have of this package is running `pubviz -o open` on a repo to see a nice web view of dependencies

At the moment, this uses assets HOSTED on github pages to wire up a single generated HTML file

The problem: there is a tight coupling between the generated HTML and the assets on github pages.

I'm wondering if we could put the web assets in `lib/assets` and when we generate the HTML we either reference the assets in the file system (since I think we can figure out where pubviz is installed).

I'd like to keep the example pretty much exactly as it is so we can host it as a demo, but maybe we just add an optional `--output` flag to `open` and `create` so we can just target the example.

Any use of `--output` should be VERY strict about not overwriting any files – but we can just script the update for the local bits is to delete example first.

Can you noodles on this?
