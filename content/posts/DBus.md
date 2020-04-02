---
title: "The D-BUS or the secret social network for programs"
date: 2020-03-31T15:33:14+13:00
draft: false
---

Programs on your computer have a secret way of talking to each other. They knows to pause music when I get a call. My spreadsheet talks to my word processor. Chrome know to open my native save file dialog. How are my programs talking to each other and why was I not invited?

Your programs talk to each other through the D-Bus. The D-Bus is this magical forum where applications yell at each other to do things or simply yell about what they are doing. It like slack for programs.

<img class="invertible" src="/posts/DBUS/UygXnF.webp"></img>

The D-Bus is this central place where all programs talk to each other at once. Each user has there own **session bus** and has access to the **system bus**. But other than that it is a free for all with many processes talking to each other, its a loud and confusing place. The main thing to get across is it is not like the web where its just a client and a server, but rather a tangle of programs talking to each other at the same time.

<img class="invertible" src="/posts/DBUS/HXJkXt.webp"></img>


---
## Snooping
So what does the D-Bus look like? Lets take a look at it with the D-Bus monitor.
```
dbus-monitor # Prints out what is happening on the dbus to the terminal
```
When dbus-monitor is running you will note that things happen now and then. If you want it to do something extra try hitting a media key or clicking on another program. Messages will be sent as the result of both of these. It won't take long for your terminal to fill up. Below is what happens when I hit the skip button when listening to music on Spotify. (I spam it a bit so don't be too scared by it)
<div class="video-card-small">
<video class="invertible" autoplay loop src="/posts/DBUS/kivcLa.mp4" controls></video>
</div>

The D-Bus is a message based system where messages tell processes to do stuff. What we see is a representation of those messages. Its very different from other IPC like HTTP(Inter Process Communication) which is simply a byte stream. The D-Bus is more of a type of RPC (Remote Procedural Calls) than classical IPC.

In the world of D-Bus it is very useful to think of a **process** as an **object**. Every process connected to the D-Bus has methods and properties. For instance "Spotify" is a process with a number of **methods**: pause, play, skip etc. Any other process (more or less as some security considerations are made) can send a message to request these methods and get a response back! (Just like in OOP) You can think of this like sending a text to a friend, you can send them a description of what you want done (arguments) and get back a response.

Secondly processes can *"subscribe"* to another process. This is how processes can be kept up to date with changes. When an object *publishes* a message it is sent to all of the parties that have subscribed. This is called a signal and it is like being on a mailing list.

#### Reading Messages

Here is the fist message that the D-Bus receives. This is a signal from the gnome shell (`:1.42`) telling all subscribers *"hey everyone someone pressed the skip song button"*. `:1.XX` is the sender/destination, processes are addressed with a unique name (like an IP). The most important processes also have specific names (like a domain name). Sadly dbus-monitor does not show these names that are much more descriptive. 
```
signal time=1585631887.955732 sender=:1.42 -> destination=:1.78 serial=7862 path=/org/gnome/Shell; interface=org.gnome.Shell; member=AcceleratorActivated
   uint32 322
   array [
      dict entry(
         string "device-id"
         variant             uint32 14
      )
      dict entry(
         string "timestamp"
         variant             uint32 27282793
      )
      dict entry(
         string "action-mode"
         variant             uint32 1
      )
      dict entry(
         string "device-node"
         variant             string "/dev/input/event6"
      )
   ]

```
The subscriber is `:1.78` which in my case has the name `org.gnome.SettingsDaemon.MediaKeys` and is responsible for doing something about the media keys. When it receives the signal it sends a message to Spotify `1.761` telling it to skip the song. Note that it is a method call rather than a signal this time.
```
method call time=1585631887.956302 sender=:1.78 -> destination=:1.761 serial=242 path=/org/mpris/MediaPlayer2; interface=org.mpris.MediaPlayer2.Player; member=Next
method return time=1585631887.956799 sender=:1.761 -> destination=:1.78 serial=1193 reply_serial=242
```

To recap. On the D-Bus processes are objects, with properties and methods. Also on the D-Bus are signals that other processes can subscribe to. When the media key is pressed the gnome shell sends out a signal to its subscribers -- *"Hey everyone, someone pressed a key"*. One of its subscribers is responsible for interpreting that signal. In this case, it tells Spotify to skip a song using a method call -- *"Hey spotify, skip a song"*. I encourage you to spend some time working out what is happening on your d-bus! For something I only recently discovered existed it sure does a bunch.

(Most of the other output in the video is Spotify telling gnome to bring up a notification. It sends an image using a byte array and updates its own properties)

* **Method Calls**, one-on-one conversation asks a program to run a procedure (RPC)
* **Properties**, processes also have properties that can be accessed
* **Signals**, Tells all subscribers that something is happening 

## Send a message
If you want to send a message you need 4 things

* **The Destination**, either the unique name  (e.g `1.761`) or its assigned name `org.mpris.MediaPlayer2.spotify`
* **The Path**, each process can have as many D-Bus objects as it wants so the path specifies which object we want
* **The Interface**, which method/interface are we sending the message to 
* **Arguments**, arguments just like a normal method.

#### Spotify Examples
*Spotify should be running*

* **Destination** `org.mpris.MediaPlayer2.spotify` could also be the unique name
* **Path** `/org/mpris/MediaPlayer2`
* **Interface** `org.mpris.MediaPlayer2.Player.<Play/Pause/Next>`

This example will tell Spotify toggle playing.

```
gdbus call --session \
   --dest=org.mpris.MediaPlayer2.spotify \
   --object-path /org/mpris/MediaPlayer2 \
   --method org.mpris.MediaPlayer2.Player.PlayPause

```

This example will tell Spotify to skip a song.

```
gdbus call --session \
   --dest=org.mpris.MediaPlayer2.spotify \
   --object-path /org/mpris/MediaPlayer2 \
   --method org.mpris.MediaPlayer2.Player.Next
```

This example will tell Spotify to play a specific song. *Note that this example requires an argument*.

```
gdbus call --session \
   --dest=org.mpris.MediaPlayer2.spotify \
   --object-path /org/mpris/MediaPlayer2 \
   --method org.mpris.MediaPlayer2.Player.OpenUri \
   "spotify:track:4uLU6hMCjMI75M1A2tKUQC"
```

Since D-Bus is inspired by Object Orientated Programming you can also get properties. This will return an object with a bunch of information about what is playing.

```
gdbus call --session \
   --dest=org.mpris.MediaPlayer2.spotify \
   --object-path /org/mpris/MediaPlayer2 \
   --method org.freedesktop.DBus.Properties.GetAll \
   "org.mpris.MediaPlayer2.Player"
```

#### VLC Examples
*VLC media player should be open*

Play something
```
gdbus call --session \
   --dest=org.mpris.MediaPlayer2.vlc \
   --object-path /org/mpris/MediaPlayer2 \
   --method org.mpris.MediaPlayer2.Player.OpenUri \
   "https://www.youtube.com/watch?v=Yw6u6YkTgQ4"
```
Toggle Play/Pause
```
gdbus call --session \
   --dest=org.mpris.MediaPlayer2.vlc \
   --object-path /org/mpris/MediaPlayer2 \
   --method org.mpris.MediaPlayer2.Player.PlayPause
```

You may have noticed something. Both spotify and VLC media player use the same interface and path. This is all part of standardization and makes is what helps make the D-Bus useful. It would be impossible to do anything if every media player had to be interacted with in a different way.

[If you want here is the specification](https://specifications.freedesktop.org/mpris-spec/latest/)

#### Gnome Examples
Send a notification!
```
gdbus call --session \
   --dest org.freedesktop.Notifications \
   --object-path /org/freedesktop/Notifications \
   --method org.freedesktop.Notifications.Notify \
   app \
   42069 \
   gtk-dialog-info \
   "Hello $USER" \
   "Have a great day $USER" \
   \[\] \
   \{\} \
   5000
```
Lock the computer!
```
gdbus call --session \
   --dest org.gnome.Shell \
   --object-path /org/gnome/ScreenSaver \
   --method org.gnome.ScreenSaver.Lock
```

### Go Explore
I strongly recommend D-Feet as a program to go pocking around the D-Bus with. It has a good GUI and everything just works.

<img class="invertible" src="/posts/DBUS/RpEBKC.webp"></img>
