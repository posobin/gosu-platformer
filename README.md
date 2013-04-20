gosu-platformer
===============
##Description
This is a simple platformer with level editor that is written in ruby with gosu.
##Prequisites
This game needs gosu library (http://libgosu.org) in order to run.
##Launching
To launch the game: `ruby game.rb`.
To launch level editor: `ruby editor.rb`.
##Guidelines
While writing this small project I tried to follow github's recommendations for ruby code (https://github.com/styleguide/ruby).
Also I used TomDoc (http://tomdoc.org) for functions documentation.
##Implementation
To speed up collision checking I used QuadTree structure (quadtree.rb file). 
It has bugs due to the way of ruby's object copying.
##Contributing
Feel free to push your changes - I will try to accept everything.
You can help me not only by sending sources, but also by recommening me some good ruby articles, pointing me to how to write test and showing me some other cool stuff - you are always welcome!
