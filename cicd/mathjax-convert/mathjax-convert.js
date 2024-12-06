const mj = require("mathjax-node");
const fs = require("fs");

mj.config({
    MathJax: {
    }
});
mj.start();

var formula = fs.readFileSync(process.argv[2], "utf-8");

mj.typeset({
    math: formula,
    format: "AsciiMath",
    svg: true,
    linebreaks: true,
}, function (data) {
    if (!data.errors) {
        const svgWithWhiteBg = data.svg.replace(/<svg(.*?)style="(.*?)"/i, '<svg$1style="$2 background-color: white;"');
        fs.writeFileSync(process.argv[3], svgWithWhiteBg);
    }
});