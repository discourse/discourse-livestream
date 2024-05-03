import { next } from "@ember/runloop";
import { withPluginApi } from "discourse/lib/plugin-api";
import DiscourseURL, { getCanonicalUrl } from "discourse/lib/url";
import { getAbsoluteURL } from "discourse-common/lib/get-url";

function updateMetadata(url, description, title) {
  if (!url.includes("conference")) {
    return;
  }
  next(() => {
    const ogTitle = document.querySelector("meta[property='og:title']");
    const ogDescription = document.querySelector(
      "meta[property='og:description']"
    );
    const ogUrl = document.querySelector("meta[property='og:url']");
    const twitterTitle = document.querySelector("meta[name='twitter:title']");
    const twitterUrl = document.querySelector("meta[name='twitter:url']");

    const canonicalUrl = document.querySelector("link[rel='canonical']");

    document.title = title;
    const absoluteUrl = getAbsoluteURL(url);
    ogDescription?.setAttribute("content", description);
    ogTitle?.setAttribute("content", title);
    ogUrl?.setAttribute("content", absoluteUrl);
    twitterTitle?.setAttribute("content", title);
    twitterUrl?.setAttribute("content", absoluteUrl);

    if (canonicalUrl) {
      canonicalUrl.setAttribute("href", getCanonicalUrl(absoluteUrl));
    }
  });
}

export default {
  name: "discourse-conference",
  initialize(owner) {
    withPluginApi("1.8.0", (api) => {
      const currentUser = api.getCurrentUser();
      const siteSettings = owner.lookup("service:site-settings");

      api.onPageChange((url) => {
        if (!url.includes("conference")) {
          document.body.classList.remove("conference-page");
          document.body.classList.remove("agenda");
        }

        if (
          currentUser &&
          localStorage.getItem("conference-user-not-signed-in")
        ) {
          localStorage.removeItem("conference-user-not-signed-in");
          DiscourseURL.redirectTo("/conference");
        }
        updateMetadata(
          url,
          siteSettings.conference_meta_description,
          siteSettings.conference_meta_title
        );
      });
    });
  },
};
