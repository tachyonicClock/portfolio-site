---
title: "Mad"
date: 2017-01-01T14:14:38+13:00
draft: true
---

Mad was one of my earliest large projects. It was coded in C# using windows forms which led to interesting challenges to get the graphics I wanted. All of the graphics were created by me. I used illustrator for the Icons, Photoshop for the map and Blender for the rockets and explosions.

The given brief was to create and educational game. I decided I would educate people about mutually assured destruction. As a result the game has a number of alternative endings based off of the outcome of the conflict. The game-play basically boils down to balancing money, time, and your relationship with the enemy. All the while you are desperately trying to build up an arsenal of nuclear weapons and anti ballistic missiles. The game normally ends in a nuclear war where both sides launch everything they have.

<button onclick="SkipToExplosions()">💥Skip To Explosions💥</button>

<script>
function SkipToExplosions(){
  var demo = document.getElementById('demo')
  demo.currentTime = 195
  demo.play();
  location.href = "#demo" 
}
</script>

<div class="videoCard">
<video id="demo" src="demo.mp4" controls></video>
</div>
