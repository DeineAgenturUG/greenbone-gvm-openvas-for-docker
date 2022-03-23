process.on('warning', e => console.warn(e.stack));
require('dotenv').config();
const toml = require("toml");
const yaml = require("js-yaml");
const inspect = require("util").inspect;

module.exports = eleventyConfig => {
  // Lower priority
  eleventyConfig.addDataExtension("toml", contents => toml.parse(contents));
  // Higher priority
  eleventyConfig.addDataExtension("yaml", contents => yaml.load(contents));

  eleventyConfig.setDataDeepMerge(true);

  eleventyConfig.addFilter("debug", (content) => `${inspect(content, {depth: 3, showHidden: true, sorted: true})}`);

  eleventyConfig.addGlobalData("build_target", (process.env.BUILD_TARGET === 'production') ? '' : '-develop');

  return {
    pathPrefix: process.env.WEB_PATH_PREFIX || '',
    /* tell Eleventy that markdown files, data files and HTML files should be processed by Nunjucks.
        That means that we can now use .html files instead of having to use .njk files */
    markdownTemplateEngine: "njk",
    dataTemplateEngine: "njk",
    htmlTemplateEngine: "njk",
    dir: {
      input: 'src',
      includes: "_includes",
      layouts: "_includes/layouts",
      data: "_data",
      output: '_generated',
    }
  };

};
