---
layout: archive
title: "CV"
permalink: /cv/
author_profile: true
redirect_from:
  - /resume
---

{% include base_path %}

Education
======
* __Ph.D__ Biostatistics, Western University
* __M.MATH__ Applied Mathematics, University of Waterloo, 2016
* __B.Sc__ Applied Mathematics, Western University, 2014

Technical Skills
======
* Python
* R
* SQL (Postgres and SQLite)
* Stan

Publications
======
  <ul>{% for post in site.publications reversed %}
    {% include archive-single-cv.html %}
  {% endfor %}</ul>

Talks
======
  <ul>{% for post in site.talks reversed %}
    {% include archive-single-talk-cv.html %}
  {% endfor %}</ul>

Teaching
======
  <ul>{% for post in site.teaching %}
    {% include archive-single-cv.html %}
  {% endfor %}</ul>


[PDF Version](http://dpananos.github.io/files/DEMETRI_CV.pdf)
