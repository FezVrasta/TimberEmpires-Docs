---
title: Home
nav_order: 1
permalink: /
hero: true
---

{% if site.halloween %}
<section class="te-section te-horde">
  <div class="te-frame">
    <div class="te-frame-head"><h2 class="te-plaque">Horde</h2></div>
    <div class="te-horde-body">
      <div class="te-pic te-trailer">
        <video id="te-trailer" preload="metadata" playsinline poster="{{ '/assets/video/horde-trailer.jpg' | relative_url }}">
          <source src="{{ '/assets/video/horde-trailer.mp4' | relative_url }}" type="video/mp4">
        </video>
        <button type="button" class="te-trailer-play" onclick="var v = document.getElementById('te-trailer'); v.controls = true; v.play(); this.hidden = true;"><span class="te-trailer-label"><svg width="22" height="22" viewBox="0 0 24 24" aria-hidden="true"><path d="M7 4.5v15l12.5-7.5z" fill="#ffb15c"></path></svg>Halloween trailer</span></button>
      </div>
      <div class="te-horde-text">
        <span class="te-horde-tag">New game mode</span>
        <p class="te-lead">Every few nights the undead raccoons crawl out of the ruins, and each horde is bigger than the last. When the badtide comes, a super horde pours out all at once. Hold the walls until sunrise, then seal the ruins for good.</p>
        <p class="te-horde-line">Fight your rivals and the horde at the same time, or team up against it. Every sunrise brings goods, buildings and siege machines you can put to use right away.</p>
        <div class="te-actions te-horde-actions">
          <a class="te-btn" href="https://steamcommunity.com/sharedfiles/filedetails/?id=3814012422">Get it on the Steam Workshop</a>
          <a class="te-btn ghost" href="{{ '/playing/horde.html' | relative_url }}">How Horde works</a>
        </div>
      </div>
    </div>
  </div>
</section>

<section class="te-section te-features">
  <div class="te-plaque-rule"><i></i><h2 class="te-plaque">New for Halloween</h2><i></i></div>
  <div class="te-tiles">
    <a class="te-tile" href="{{ '/buildings/flamethrower.html' | relative_url }}"><span class="te-medal"><img src="{{ '/assets/icons/Flamethrower.png' | relative_url }}" alt=""></span><span class="te-tile-title">Flamethrower</span><span class="te-tile-text te-flavor-text">Extract in, ashes out.</span></a>
    <a class="te-tile" href="{{ '/playing/horde.html#pumpkins' | relative_url }}"><span class="te-medal"><img src="{{ '/assets/icons/Pumpkin.png' | relative_url }}" alt=""></span><span class="te-tile-title">Pumpkin</span><span class="te-tile-text te-flavor-text">Carved, it lights up the night. Eaten raw, it cures the badwater sickness from an undead raccoon's bite.</span></a>
    <a class="te-tile" href="{{ '/playing/horde.html#candy-buckets' | relative_url }}"><span class="te-medal"><img src="{{ '/assets/icons/CandyBucket.png' | relative_url }}" alt=""></span><span class="te-tile-title">Candy Bucket</span><span class="te-tile-text te-flavor-text">Someone's trick-or-treat haul. Nobody came back for it.</span></a>
    <a class="te-tile" href="{{ '/playing/horde.html#will-o-the-wisps' | relative_url }}"><span class="te-medal"><img src="{{ '/assets/icons/WillOWisp.png' | relative_url }}" alt=""></span><span class="te-tile-title">Will-o'-the-Wisp</span><span class="te-tile-text te-flavor-text">A pale flame drifting over the ruins.</span></a>
  </div>
</section>
{% else %}
<section class="te-intro-row">
  <div class="te-intro-text">
    <p class="te-lead">Everyone plays on the same map, with their own districts and their own research. You can send troops, siege machines and fireships at anyone.</p>
    <p>Multiplayer runs on <a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3813984327">BeaverBuddies Co-Op/PvP Edition</a>. You can also play alone against the bandits and AI opponents.</p>
  </div>
  <div class="te-frame te-trailer">
    <video id="te-trailer" preload="metadata" playsinline poster="{{ '/assets/video/launch-trailer.jpg' | relative_url }}">
      <source src="{{ '/assets/video/launch-trailer.mp4' | relative_url }}" type="video/mp4">
    </video>
    <button type="button" class="te-trailer-play" onclick="var v = document.getElementById('te-trailer'); v.controls = true; v.play(); this.hidden = true;"><span class="te-trailer-label"><svg width="22" height="22" viewBox="0 0 24 24" aria-hidden="true"><path d="M7 4.5v15l12.5-7.5z" fill="#d9584b"></path></svg>Launch trailer</span></button>
  </div>
</section>
{% endif %}

<section class="te-section te-modes">
  <div class="te-plaque-rule"><i></i><h2 class="te-plaque">Game modes</h2><i></i></div>
  <div class="te-mode-grid">
    <a class="te-mode" href="{{ '/game-modes.html#co-op' | relative_url }}"><span class="te-medal"><img src="{{ '/assets/icons/TradingPost.png' | relative_url }}" alt=""></span><span class="te-mode-text"><span class="te-mode-title">Co-op</span><span class="te-mode-against">Against nobody</span><span class="te-mode-desc">Everyone builds one settlement together. No bandits, no winner.</span></span></a>
    <a class="te-mode" href="{{ '/game-modes.html#pve' | relative_url }}"><span class="te-medal"><img src="{{ '/assets/icons/BanditCamp.png' | relative_url }}" alt=""></span><span class="te-mode-text"><span class="te-mode-title">PvE</span><span class="te-mode-against">Against the bandits</span><span class="te-mode-desc">Everyone is allied. Clear every bandit camp and you all win.</span></span></a>
    <a class="te-mode" href="{{ '/game-modes.html#pvp' | relative_url }}"><span class="te-medal"><img src="{{ '/assets/icons/Barracks.png' | relative_url }}" alt=""></span><span class="te-mode-text"><span class="te-mode-title">PvP</span><span class="te-mode-against">Against each other</span><span class="te-mode-desc">Everyone for themselves, and the bandits raid everyone.</span></span></a>
    <a class="te-mode featured" href="{{ '/playing/horde.html' | relative_url }}"><img class="te-mode-art" src="{{ '/assets/images/horde-1280.webp' | relative_url }}" alt=""><span class="te-medal"><img src="{{ '/assets/icons/HordeJaws.svg' | relative_url }}" alt=""></span><span class="te-mode-text"><span class="te-mode-title">Horde</span><span class="te-mode-against">Against each other and the undead</span><span class="te-mode-desc">Fight your rivals and the horde at the same time, or team up against it.</span></span></a>
    <a class="te-mode" href="{{ '/game-modes.html#playing-alone' | relative_url }}"><span class="te-medal"><img src="{{ '/assets/icons/Gatehouse.png' | relative_url }}" alt=""></span><span class="te-mode-text"><span class="te-mode-title">Alone</span><span class="te-mode-against">Against bandits or AIs</span><span class="te-mode-desc">Play as an empire against the bandits, or add AI opponents.</span></span></a>
  </div>
  <div class="te-center"><a class="te-btn ghost" href="{{ '/game-modes.html' | relative_url }}">How the modes work</a></div>
</section>

<section class="te-section te-features">
  <div class="te-plaque-rule"><i></i><h2 class="te-plaque">What's in it</h2><i></i></div>
  <div class="te-tiles">
    <a class="te-tile" href="{{ '/playing/territory.html' | relative_url }}"><span class="te-medal"><img src="{{ '/assets/icons/ClaimFlag.png' | relative_url }}" alt=""></span><span class="te-tile-title">Territory</span><span class="te-tile-text">Claim land and hold on to it.</span></a>
    <a class="te-tile" href="{{ '/military/' | relative_url }}"><span class="te-medal"><img src="{{ '/assets/icons/Catapult.png' | relative_url }}" alt=""></span><span class="te-tile-title">War</span><span class="te-tile-text">Train an army and break through their walls.</span></a>
    <a class="te-tile" href="{{ '/playing/rivers.html' | relative_url }}"><span class="te-medal"><img src="{{ '/assets/icons/MineLauncher.png' | relative_url }}" alt=""></span><span class="te-tile-title">Rivers</span><span class="te-tile-text">Send mines and fireships downstream.</span></a>
    <a class="te-tile" href="{{ '/playing/alliances.html' | relative_url }}"><span class="te-medal"><img src="{{ '/assets/icons/Alliances.png' | relative_url }}" alt=""></span><span class="te-tile-title">Alliances</span><span class="te-tile-text">Team up with other players, or fight everyone.</span></a>
  </div>
  <div class="te-center"><a class="te-btn ghost" href="{{ '/playing/' | relative_url }}">See all features</a></div>
</section>

<section class="te-section te-findway">
  <div class="te-frame">
    <div class="te-frame-head"><h2 class="te-plaque">Find your way</h2></div>
    <div class="te-links">
      <a class="te-link" href="{{ '/getting-started.html' | relative_url }}"><span class="te-gem" aria-hidden="true"></span>Getting started</a>
      <a class="te-link" href="{{ '/game-modes.html' | relative_url }}"><span class="te-gem" aria-hidden="true"></span>Game modes</a>
      <a class="te-link" href="{{ '/ai-opponents.html' | relative_url }}"><span class="te-gem" aria-hidden="true"></span>AI opponents</a>
      <a class="te-link" href="{{ '/settings.html' | relative_url }}"><span class="te-gem" aria-hidden="true"></span>Settings</a>
      <a class="te-link" href="{{ '/buildings/' | relative_url }}"><span class="te-gem" aria-hidden="true"></span>Buildings</a>
      <a class="te-link" href="{{ '/troops/' | relative_url }}"><span class="te-gem" aria-hidden="true"></span>Troops</a>
      <a class="te-link" href="{{ '/modding.html' | relative_url }}"><span class="te-gem" aria-hidden="true"></span>Modding</a>
    </div>
  </div>
</section>
