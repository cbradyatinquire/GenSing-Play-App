============
INTRODUCTION
============

This Repository contains the current state of work on a webapp for the GenSing/CN-ECT for Maths project.
This is the back-end software, which handles incoming classroom data, saves them into a MySQL database, 
as well as serve requests for the visualizers which loads the data in a graphical way ( The Graphic Visualizer, The Live Wave, and The Live Spiral Visualizer ) .

Please see below for Software Requirements, Installation Guide and User's Guide.

=====================
SOFTWARE REQUIREMENTS
=====================
GenSing Web-App Software Requirements:

1. Oracle Java JVM 7
2. Play! Framework v1.2.2
3. MySQL


============
INSTALLATION
============

Installing Oracle JVM 7:

1. Oracle JVM 7 is required by the Play! Framework (please note that only Oracle JVM 7 will work with Play! Framework. OpenJDK or other Java implementations is not guaranteed to work)
2. How to install Oracle JVM 7 is not covered here, please consult official installation instructions from Oracle.

Installing Play! Framework:

1. Go to: http://www.playframework.com/download and download Downloads/play-1.2.2.zip
2. Unzip to desired location (e.g. /home/ubuntu/)
3. Check that Play! Framework is properly installed by running one of the included demos (e.g. forum):
NOTE: Please ensure that you have Oracle JVM 7 installed beforehand

$ cd ~/play-1.2.2/samples-and-tests/forum/
$ ~/play-1.2.2/play run

4. The terminal should show:

~        _            _ 
~  _ __ | | __ _ _  _| |
~ | '_ \| |/ _' | || |_|
~ |  __/|_|\____|\__ (_)
~ |_|            |__/   
~
~ play! 1.2.2, http://www.playframework.org
~
~ Ctrl+C to stop
~ 
Listening for transport dt_socket at address: 8000
07:59:58,887 INFO  ~ Starting /home/ubuntu/play-1.2.2/samples-and-tests/forum
07:59:59,984 WARN  ~ You're running Play! in DEV mode
08:00:00,273 INFO  ~ Listening for HTTP on port 9000 (Waiting a first request to start) ...

5. Open a web browser and go to http://localhost:9000 
6. If you can access it, Play! Framework has been installed successfully


Installing MySQL:

1. The GenSing web-app uses MySQL v5 as the database back end. How to install MySQL is not covered here, as most systems already have it installed and you may want to check out the official installation instructions from Oracle.


Installing GenSing Web-App:

1. Once you have Oracle Java 7, Play! framework v1.2.2 and MySQL 5 installed, you are ready to install the GenSing Web-App.

2. Using Git, clone it from the GitHub repo:
NOTE: please ensure that you have Git installed on your system (on Ubuntu, his can be done by $ sudo apt-get install git)

$ git clone http://www.github.com/cbradyatinquire/GenSing-Play-App

3. Point the database CRUD module of the GenSing-Play-App to the play-1.2.2 CRUD module that is installed on your system:

- edit file GenSing-Play-App/modules/crud 
- make sure the path to the file is correct 
- for example, if your Play! Framework is installed on /home/ubuntu/play-1.2.2, make sure the first line looks like the following: /home/ubuntu/play-1.2.2/modules/crud

4. Navigate to the GenSing-Play-App directory, then execute play with:

$ ~/play-1.2.2/play run

5. In a browser, go to http://localhost:9000 to start it. It will prompt you that the database is in inconsistent state, you need to click "Mark it resolved" / "Apply evolutions" until you reached the main page. This is because throughout the development, the database structure has gone through a few rounds of evolutions. You need to apply all the evolutions in order to get to the latest state.

6. Congratulations! its up and running on your server! :)

(NOTE: This is running GenSing-Play-App in Development mode, which is useful when developing software, but the database is volatile - all data will be erased on server shutdown. To run GenSing-Play-App in Production mode with a persistent MySQL database, see "Going To Production Mode.txt")


==========
USER GUIDE
==========

Using the Live Spiral Visualizer

1. Go to the "Visualizer Chooser" page or type http://your-server-address:9000/schoolPicker

2. Specify the session you're interested in, by narrowing down from school - teacher - class - session

3. Select "Spiral" 

4. You can increase / decrease font size, roate clockwise, counter clockwise or reset to starting position, and show ONLY VALID equations / ONLY INVALID equations / ALL equations.

5. As a contribution came in from a student in an ongoing session, it will be displayed in the Spiral in very near real-time ( less than 5 secs )



Using the Live Wave Visualizer

1. Go to the "Visualizer Chooser" page or type http://your-server-address:9000/schoolPicker

2. Specify the session you're interested in, by narrowing down from school - teacher - class - session

3. Select "Wave" 

4. You can show ONLY VALID equations / ONLY INVALID equations / ALL equations. NOTE: The Live Wave is computationally much heavier than the Live Spiral, depending on your computer's processor, it may not be as responsive as the Live Spiral. Please allow a split second between hovering over an item and clicking it.

5. You can add annotation and coding to an equation by first hovering over an interesting equation (wait for the enlarged text to appear), then right-click. A pop-up window will open where you can type in your annotation and assign codings to the equation. NOTE: Please ensure that your browser allows pop-up windows.

6. You can select/highlight equations by first hovering over them and left-clicking. Notice the pinkish shade of a selected equation. Then you can re-arrange the display by clicking on "Sort". This will move STUDENTS who contributed identical equations to the top. 

7. You can save the sorted display ordering and reload them in future.

8. As a contribution came in from a student in an ongoing session, it will be displayed in the Wave in very near real-time ( less than 5 secs )
 



Using the GraphicVisualizer

1. In a browser, go to http://your-server-address:9000/graphicVisualizer to access the GraphicVisualizer

2. Because the page uses Geogebra's live graphing, loading the page will take a while. Upon loading, you will see "CAS initializing" on the top left corner of your browser, signifying that the page is loading Geogebra's graphing module. Simply wait for a while until it finishes loading. If you get prompted by your browser that a script is not responding, just click continue with the script and it will eventually load.

3. Specify a set of contributions to load by expanding on the tree at the top and ticking the subsets you're interested in. Please note, at the very least, you must specify BOTH a session and contributions from a student. Then click "Load Data Into Table" and the desired data will be loaded to a table below.

4. To select another sub-set of data, click "Select New Data From Tree" and specify it by ticking on the tree.

5. To graph an equation contributed by the students, click on the math expression. 

6. To add annotation to an interesting equation, click on the row's "Codings" or "Annotations" column. A popup will appear where you can type in the annotations, or assign codes to the equation.
NOTE: Please ensure that your browser allows popup windows

7. You can manage the Codings by clicking on "Manage Codes" at the top of the page.

8. To assess whether the loaded equations are equivalent to some math expression, click "Assess Contributions". A popup will then appear where you type in the target equation. Clicking OK will assess all the loaded equations whether they are equivalent to the target or not. NOTE: only VALID contributions will be assessed. 


=======
LICENSE
=======

GenSing Graphical Viewer by Sarah M. Davis and Corey C. Brady is licensed under a Creative Commons Attribution 3.0 Unported License

