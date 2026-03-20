There are 4 interacitve elements:

(1) hover behavior - changes color
(2) hover behavior - prints info to console
(3) zoom button
(4) click element "hides" it.

# Future

I'd like to have a "controls" section around where the zoom button is now.
Let's have the controls collapsed by default using a hamburger and expand on the left
I want the controls to ALWAYS push the graph to the left – so I don't want them rendered OVER

So the zoom button goes in there.
I want zoom to have a keyboard shortcut of 'z' - which does the toggle.
I want the zoom to be an actual checkbox, not a button.
The "z" key should work even if controls are closed.

Let's start with this and go from there!

You can run the "app" using ~/github/kevmoo/pubviz/bin/pubviz.dart -o open --workspace ~/github/genkit-dart

It will print out a temporary path that you can open in your browser to see how things look!

Maybe FIRST we should add a `create` that basically does what `open` does WITHOUT opening the browser - so you can do it yourself.