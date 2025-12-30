{pkgs, ...}: {
  programs.firefox = {
    enable = true;

    policies = {
      DisableTelemetry = false;
      DisableFirefoxStudies = false;
      DisableCrashReporter = false;
      DontCheckDefaultBrowser = true;
      PasswordManagerEnabled = false;

      FirefoxSuggest = {
        WebSuggestions = false;
        SponsoredSuggestions = false;
        ImproveSuggest = false;
      };
      SearchSuggestEnabled = false;

      FirefoxHome = {
        Search = true;
        TopSites = false;
        SponsoredTopSites = false;
        Highlights = false;
        Pocket = false;
        SponsoredPocket = false;
        Snippets = false;
      };

      Cookies = {
        ExpireAtSessionEnd = true;
      };
      Permissions = {
        Camera = {
          BlockNewRequests = true;
          Default = "block";
        };
        Microphone = {
          BlockNewRequests = true;
          Default = "block";
        };
      };

      HttpsOnlyMode = "force_enabled";
      DNSOverHTTPS = {
        Enabled = false;
      };
    };

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
        "browser.download.useDownloadDir" = false;
        "network.trr.mode" = 5;
        "browser.webcompat.fixes" = true;
        "privacy.antitracking.enableWebcompat" = true;
        "privacy.trackingprotection.allow_list.convenience.enabled" = true;
        "dom.security.https_only_mode" = true;
        "privacy.sanitize.sanitizeOnShutdown" = true;
        "privacy.clearOnShutdown.cookies" = true;
        "privacy.clearOnShutdown.sessions" = true;

        "datareporting.healthreport.uploadEnabled" = true;
        "datareporting.policy.dataSubmissionEnabled" = true;
        "datareporting.usage.uploadEnabled" = true;
        "browser.newtabpage.activity-stream.telemetry" = true;
        "app.shield.optoutstudies.enabled" = true;
        "app.normandy.enabled" = true;
        "browser.tabs.crashReporting.sendReport" = true;

        "browser.search.suggest.enabled" = false;
        "browser.urlbar.suggest.searches" = false;
        "browser.urlbar.showSearchSuggestionsFirst" = false;
        "browser.urlbar.quicksuggest.enabled" = false;
        "browser.urlbar.suggest.quicksuggest.nonsponsored" = false;
        "browser.urlbar.suggest.quicksuggest.sponsored" = false;
        "browser.urlbar.suggest.engines" = false;
        "browser.urlbar.suggest.topsites" = false;
        "browser.urlbar.trending.featureGate" = false;

        "network.http.speculative-parallel-limit" = 0;
        "network.dns.disablePrefetch" = true;
        "network.dns.disablePrefetchFromHTTPS" = true;
        "browser.urlbar.speculativeConnect.enabled" = false;
        "browser.places.speculativeConnect.enabled" = false;
        "network.prefetch-next" = false;
        "network.predictor.enabled" = false;
        "gfx.webrender.layer-compositor" = true;
        "media.wmf.zero-copy-nv12-textures-force-enabled" = true;

        "browser.contentblocking.category" = "strict";
        "privacy.trackingprotection.allow_list.baseline.enabled" = true;
        "browser.helperApps.deleteTempFileOnExit" = true;
        "browser.uitour.enabled" = false;
        "privacy.globalprivacycontrol.enabled" = true;
        "security.OCSP.enabled" = 0;
        "security.csp.reporting.enabled" = false;
        "security.ssl.treat_unsafe_negotiation_as_broken" = true;
        "browser.xul.error_pages.expert_bad_cert" = true;
        "security.tls.enable_0rtt_data" = false;
        "browser.privatebrowsing.forceMediaMemoryCache" = true;
        "browser.sessionstore.interval" = 60000;
        "privacy.history.custom" = true;
        "security.mixed_content.block_display_content" = true;
        "pdfjs.enableScripting" = false;
        "extensions.enabledScopes" = 5;
        "network.http.referer.XOriginTrimmingPolicy" = 0;
        "privacy.userContext.ui.enabled" = true;
        "browser.safebrowsing.downloads.remote.enabled" = false;
        "permissions.default.desktop-notification" = 2;
        "permissions.default.geo" = 2;
        "geo.provider.network.url" = "https://beacondb.net/v1/geolocate";
        "permissions.manager.defaultsUrl" = "";

        "extensions.htmlaboutaddons.recommendations.enabled" = false;
        "browser.discovery.enabled" = false;
        "browser.shell.checkDefaultBrowser" = false;
        "browser.newtabpage.activity-stream.asrouter.userprefs.cfr.addons" = false;
        "browser.newtabpage.activity-stream.asrouter.userprefs.cfr.features" = false;
        "browser.aboutConfig.showWarning" = false;
        "browser.aboutwelcome.enabled" = false;
        "browser.profiles.enabled" = true;
        "browser.urlbar.scotchBonnet.enableOverride" = false;
        "full-screen-api.transition-duration.enter" = "0 0";
        "full-screen-api.transition-duration.leave" = "0 0";
        "full-screen-api.warning.timeout" = 0;
        "browser.newtabpage.activity-stream.default.sites" = "";
        "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
        "browser.newtabpage.activity-stream.feeds.section.topstories" = false;
        "browser.newtabpage.activity-stream.feeds.section.highlights" = false;
        "browser.newtabpage.activity-stream.showSponsored" = false;
        "browser.newtabpage.activity-stream.showSponsoredCheckboxes" = false;
        "browser.download.manager.addToRecentDocs" = false;
        "findbar.highlightAll" = true;
        "layout.word_select.eat_space_to_next_word" = false;
      };
    };
  };
}
