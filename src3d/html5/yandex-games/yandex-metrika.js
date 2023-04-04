// Yandex Metrica Tools
"use strict";

const YA_METRICA_ID = 92990425;

(function(m,e,t,r,i,k,a){m[i]=m[i]||function(){(m[i].a=m[i].a||[]).push(arguments)};
m[i].l=1*new Date();k=e.createElement(t),a=e.getElementsByTagName(t)[0],k.async=1,k.src=r,a.parentNode.insertBefore(k,a)})
(window, document, "script", "https://mc.yandex.ru/metrika/tag.js", "ym");

ym(YA_METRICA_ID, "init", {
     clickmap:true,
     trackLinks:true,
     accurateTrackBounce:true
});

window.ymReachGoal = function(goal) {
    ym(YA_METRICA_ID, "reachGoal", goal);
  }
  