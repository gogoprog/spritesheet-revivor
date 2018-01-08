$(function() {
  'use strict';
  'esversion: 6';

  class Point {
    constructor(x, y) {
      this.x = x;
      this.y = y;
    }
  }

  class Rectangle {
    constructor(from, to) {
      this.from = from;
      this.to = to;
    }

    width() { return this.to.x - this.from.x + 1; }
    height() { return this.to.y - this.from.y + 1; }
  }

  function isZero(data, p) {
    return !data[p] && !data[p + 1] && !data[p + 2] && !data[p + 3];
  }

  console.log("Spritesheet Revivor");

  let sourceCanvas = $("#source");
  let sourceCtx = sourceCanvas[0].getContext('2d');
  let previewCanvas = $("#preview");
  let previewCtx = previewCanvas[0].getContext('2d');

  sourceCanvas.click(function(e) {
    let x = e.offsetX;
    let y = e.offsetY;
    console.log(x, y);
    let found = false;
    let it = 0;

    let rect = new Rectangle(new Point(x - 2, y - 2), new Point(x + 2, y + 2));

    while (it < 1000) {
      let w = rect.width();
      let h = rect.height();
      let data = sourceCtx.getImageData(rect.from.x, rect.from.y, w, h);
      let found = true;

      for (let i = 0; i < w; ++i) {
        let p = i * 4;
        if (!isZero(data.data, p)) {
          rect.from.y--;
          found = false;
          break;
        }
      }

      for (let i = 0; i < w; ++i) {
        let p = (w * (h - 1) * 4) + i * 4;
        if (!isZero(data.data, p)) {
          rect.to.y++;
          found = false;
          break;
        }
      }

      for (let i = 0; i < h; ++i) {
        let p = w * i * 4;
        if (!isZero(data.data, p)) {
          rect.from.x--;
          found = false;
          break;
        }
      }
      for (let i = 0; i < h; ++i) {
        let p = w * i * 4 + (w - 1) * 4;
        if (!isZero(data.data, p)) {
          rect.to.x++;
          found = false;
          break;
        }
      }
      ++it;

      if (found) {
        console.log(rect);
        previewCtx.clearRect(0, 0, 512, 512);
        previewCtx.putImageData(data, 0, 0);
        break;
      }
    }

  });

  let img = new Image();
  img.src = "megaman.png";
  img.onload = function() { sourceCtx.drawImage(img, 0, 0); };

});
