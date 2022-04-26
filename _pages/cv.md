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
* __M.Sc.__ Biostatistics, Brown University, (expected 2023)
* __B.Sc__ Biostatistics, Jomo Kenyatta University, 2021

Technical Skills
======
* SAS
* R
* MySQL
* Stata

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
