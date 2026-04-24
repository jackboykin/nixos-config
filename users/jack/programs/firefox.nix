{
  config,
  theme,
  ...
}: {
  programs.firefox = {
    enable = true;
    configPath = "${config.xdg.configHome}/mozilla/firefox";

    profiles.jack = {
      isDefault = true;
      settings = {
        "privacy.sanitize.sanitizeOnShutdown" = true;
        "privacy.clearOnShutdown_v2.cookiesAndStorage" = true;
        "privacy.clearOnShutdown_v2.cache" = true;
        "browser.aboutConfig.showWarning" = false;
        "browser.aboutwelcome.enabled" = false;

        "browser.contentblocking.category" = "strict";
        "layout.frame_rate" = 144;

        "browser.discovery.enabled" = false;
        "browser.download.manager.addToRecentDocs" = false;
        "browser.newtabpage.activity-stream.asrouter.userprefs.cfr.addons" = false;
        "browser.newtabpage.activity-stream.asrouter.userprefs.cfr.features" = false;
        "browser.newtabpage.activity-stream.default.sites" = "";
        "browser.newtabpage.activity-stream.feeds.topsites" = false;
        "browser.newtabpage.activity-stream.feeds.section.topstories" = false;
        "browser.newtabpage.activity-stream.showSponsored" = false;
        "browser.newtabpage.activity-stream.showSponsoredCheckboxes" = false;
        "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
        "browser.places.speculativeConnect.enabled" = false;
        "browser.profiles.enabled" = true;
        "browser.safebrowsing.downloads.remote.enabled" = false;
        "browser.sessionstore.interval" = 60000;
        "browser.shell.checkDefaultBrowser" = false;
        "browser.uitour.enabled" = false;
        "browser.urlbar.speculativeConnect.enabled" = false;
        "browser.urlbar.trending.featureGate" = false;
        "extensions.enabledScopes" = 5;
        "extensions.htmlaboutaddons.recommendations.enabled" = false;
        "findbar.highlightAll" = true;
        "full-screen-api.transition-duration.enter" = "0 0";
        "full-screen-api.transition-duration.leave" = "0 0";
        "full-screen-api.warning.timeout" = 0;
        "layout.word_select.eat_space_to_next_word" = false;
        "dom.security.https_only_mode" = true;
        "network.trr.mode" = 5;
        "network.dns.disablePrefetch" = true;
        "network.dns.disablePrefetchFromHTTPS" = true;
        "network.http.referer.XOriginTrimmingPolicy" = 2;
        "network.http.speculative-parallel-limit" = 0;
        "network.prefetch-next" = false;
        "pdfjs.enableScripting" = false;
        "permissions.default.camera" = 2;
        "permissions.default.desktop-notification" = 2;
        "permissions.default.geo" = 2;
        "permissions.default.microphone" = 2;
        "privacy.globalprivacycontrol.enabled" = true;
        "privacy.userContext.ui.enabled" = true;
        "security.OCSP.enabled" = 0;
        "security.csp.reporting.enabled" = false;
        "security.mixed_content.block_display_content" = true;
        "security.ssl.treat_unsafe_negotiation_as_broken" = true;
        "security.tls.enable_0rtt_data" = false;
        "signon.management.page.enabled" = false;
        "signon.rememberSignons" = false;
        "font.name.sans-serif.x-western" = "Inter";
        "font.name.serif.x-western" = "Noto Serif";
        "font.name.monospace.x-western" = theme.fonts.mono.name;
        "font.size.variable.x-western" = 16;
        "font.default.x-western" = "sans-serif";
        "gfx.font_rendering.fontconfig.max_generic_substitutions" = 127;
        "browser.urlbar.shortcuts.bookmarks" = false;
        "browser.urlbar.shortcuts.history" = false;
        "browser.urlbar.shortcuts.tabs" = false;
        "browser.toolbars.bookmarks.visibility" = "never";
        "browser.urlbar.trimURLs" = false;
        "media.peerconnection.ice.default_address_only" = true;
      };
    };
  };
}
