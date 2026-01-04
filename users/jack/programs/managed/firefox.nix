{pkgs, ...}: {
  programs.firefox = {
    enable = true;

    profiles.jack = {
      isDefault = true;

      extensions.packages = with pkgs.nur.repos.rycee.firefox-addons; [
        ublock-origin
        proton-pass
        violentmonkey
        (pkgs.nur.repos.rycee.firefox-addons."7tv")
        twitch-auto-points
      ];

      settings = {
        "browser.aboutConfig.showWarning" = false;
        "browser.aboutwelcome.enabled" = false;
        "browser.contentblocking.category" = "strict";
        "browser.discovery.enabled" = false;
        "browser.download.manager.addToRecentDocs" = false;
        "browser.helperApps.deleteTempFileOnExit" = true;
        "browser.newtabpage.activity-stream.asrouter.userprefs.cfr.addons" = false;
        "browser.newtabpage.activity-stream.asrouter.userprefs.cfr.features" = false;
        "browser.newtabpage.activity-stream.default.sites" = "";
        "browser.newtabpage.activity-stream.feeds.topsites" = false;
        "browser.newtabpage.activity-stream.feeds.section.topstories" = false;
        "browser.newtabpage.activity-stream.showSponsored" = false;
        "browser.newtabpage.activity-stream.showSponsoredCheckboxes" = false;
        "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
        "browser.places.speculativeConnect.enabled" = false;
        "browser.privatebrowsing.forceMediaMemoryCache" = true;
        "browser.profiles.enabled" = true;
        "browser.safebrowsing.downloads.remote.enabled" = false;
        "browser.sessionstore.interval" = 60000;
        "browser.shell.checkDefaultBrowser" = false;
        "browser.uitour.enabled" = false;
        "browser.urlbar.scotchBonnet.enableOverride" = false;
        "browser.urlbar.speculativeConnect.enabled" = false;
        "browser.urlbar.trending.featureGate" = false;
        "browser.xul.error_pages.expert_bad_cert" = true;
        "extensions.enabledScopes" = 5;
        "extensions.htmlaboutaddons.recommendations.enabled" = false;
        "findbar.highlightAll" = true;
        "full-screen-api.transition-duration.enter" = "0 0";
        "full-screen-api.transition-duration.leave" = "0 0";
        "full-screen-api.warning.timeout" = 0;
        "geo.provider.network.url" = "https://beacondb.net/v1/geolocate";
        "gfx.webrender.layer-compositor" = true;
        "layout.word_select.eat_space_to_next_word" = false;
        "media.wmf.zero-copy-nv12-textures-force-enabled" = true;
        "network.cookie.lifetimePolicy" = 2;
        "network.dns.disablePrefetch" = true;
        "network.dns.disablePrefetchFromHTTPS" = true;
        "network.http.referer.XOriginTrimmingPolicy" = 2;
        "network.http.speculative-parallel-limit" = 0;
        "network.predictor.enabled" = false;
        "network.prefetch-next" = false;
        "pdfjs.enableScripting" = false;
        "permissions.default.camera" = 2;
        "permissions.default.desktop-notification" = 2;
        "permissions.default.geo" = 2;
        "permissions.default.microphone" = 2;
        "permissions.manager.defaultsUrl" = "";
        "privacy.globalprivacycontrol.enabled" = true;
        "privacy.trackingprotection.allow_list.baseline.enabled" = true;
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
        "font.name.monospace.x-western" = "JetBrainsMono Nerd Font";
        "font.size.variable.x-western" = 16;
        "font.default.x-western" = "sans-serif";
        "gfx.webrender.all" = true;
        "gfx.canvas.accelerated" = true;
        "gfx.font_rendering.fontconfig.max_generic_substitutions" = 127; # Better font fallback
        "browser.display.use_document_fonts" = 1; # Allow pages to use their own fonts
      };
    };
  };
}
