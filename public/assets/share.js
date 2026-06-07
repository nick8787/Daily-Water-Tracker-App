(function () {
  "use strict";

  var DISTRIBUTION_URL =
    "https://appdistribution.firebase.dev/i/38466fc6f0cdf4e4";

  var STORES = {
    dev: {
      ios: DISTRIBUTION_URL,
      android: DISTRIBUTION_URL,
      showDevBadge: true,
    },
    prod: {
      ios: "https://testflight.apple.com/join/ngaktaYQ",
      android: "https://appdistribution.firebase.dev/i/bd355ff115b1194f",
      showDevBadge: false,
    },
  };

  var I18N = {
    en: {
      appName: "Daily Water Tracker",
      devBadge: "Dev",
      sharedProgress: "Shared progress",
      drankToday: "drank today",
      sharedMessage:
        "A friend shared their daily hydration progress with you.",
      genericMessage: "Track your daily water intake and stay hydrated.",
      ctaTitle: "Track yours too",
      iosButtonDev: "Install on iOS",
      androidButtonDev: "Install on Android",
      iosButtonProd: "Get on TestFlight",
      androidButtonProd: "Get on Android",
      qrLabel: "Scan to download on your phone",
      footerInstalled:
        "Already have the app? Open the same link on your phone — it will launch automatically.",
    },
    uk: {
      appName: "Daily Water Tracker",
      devBadge: "Dev",
      sharedProgress: "Спільний прогрес",
      drankToday: "випито сьогодні",
      sharedMessage: "Друг поділився своїм денним прогресом гідратації з тобою.",
      genericMessage:
        "Відстежуй щоденне споживання води та підтримуй водний баланс.",
      ctaTitle: "Відстежуй і свій прогрес",
      iosButtonDev: "Встановити на iOS",
      androidButtonDev: "Встановити на Android",
      iosButtonProd: "Завантажити з TestFlight",
      androidButtonProd: "Завантажити на Android",
      qrLabel: "Скануй, щоб завантажити на телефон",
      footerInstalled:
        "Застосунок уже встановлено? Відкрий це посилання на телефоні — воно запуститься автоматично.",
    },
  };

  function detectLang() {
    var languages = navigator.languages || [navigator.language || "en"];
    for (var i = 0; i < languages.length; i += 1) {
      var code = String(languages[i] || "").toLowerCase();
      if (code.indexOf("uk") === 0) {
        return "uk";
      }
    }
    return "en";
  }

  function detectEnv() {
    var host = window.location.hostname.toLowerCase();
    if (host.indexOf("-dev") !== -1 || host.indexOf(".dev.") !== -1) {
      return "dev";
    }
    return "prod";
  }

  function detectPlatform() {
    var ua = navigator.userAgent || "";
    if (/android/i.test(ua)) return "android";
    if (/iphone|ipad|ipod/i.test(ua)) return "ios";
    return "desktop";
  }

  function parseMl() {
    var params = new URLSearchParams(window.location.search);
    var raw = (params.get("ml") || "").trim();
    var ml = parseInt(raw, 10);
    if (!Number.isFinite(ml) || ml <= 0 || ml > 99999) {
      return null;
    }
    return ml;
  }

  function formatMl(ml, lang) {
    var locale = lang === "uk" ? "uk-UA" : "en-US";
    return new Intl.NumberFormat(locale).format(ml);
  }

  function t(lang, key) {
    return (I18N[lang] && I18N[lang][key]) || I18N.en[key] || key;
  }

  function buttonLabels(lang, env) {
    if (env === "dev") {
      return {
        ios: t(lang, "iosButtonDev"),
        android: t(lang, "androidButtonDev"),
      };
    }
    return {
      ios: t(lang, "iosButtonProd"),
      android: t(lang, "androidButtonProd"),
    };
  }

  function pickStoreUrl(stores, platform) {
    if (platform === "ios") return stores.ios;
    if (platform === "android") return stores.android;
    return stores.ios || stores.android || "";
  }

  function renderQrImage(img, url) {
    if (!img || !url) return;
    img.src =
      "https://api.qrserver.com/v1/create-qr-code/?size=168x168&color=12-160-230&bgcolor=ffffff&margin=10&data=" +
      encodeURIComponent(url);
  }

  function applyStoreButtons(stores, platform, lang, env) {
    var labels = buttonLabels(lang, env);
    var iosBtn = document.getElementById("ios-button");
    var androidBtn = document.getElementById("android-button");
    var hasStores = Boolean(stores.ios || stores.android);

    if (!hasStores) {
      if (iosBtn) iosBtn.classList.add("is-hidden");
      if (androidBtn) androidBtn.classList.add("is-hidden");
      return false;
    }

    if (iosBtn && stores.ios) {
      iosBtn.href = stores.ios;
      iosBtn.classList.remove("is-hidden");
      setText("ios-button-label", labels.ios);
      iosBtn.classList.toggle("store-button--secondary", platform === "android");
    } else if (iosBtn) {
      iosBtn.classList.add("is-hidden");
    }

    if (androidBtn && stores.android) {
      androidBtn.href = stores.android;
      androidBtn.classList.remove("is-hidden");
      setText("android-button-label", labels.android);
      androidBtn.classList.toggle("store-button--secondary", platform === "ios");
    } else if (androidBtn) {
      androidBtn.classList.add("is-hidden");
    }

    if (platform === "ios" && stores.ios && iosBtn) {
      iosBtn.classList.remove("store-button--secondary");
      if (androidBtn) androidBtn.classList.add("store-button--secondary");
    } else if (platform === "android" && stores.android && androidBtn) {
      androidBtn.classList.remove("store-button--secondary");
      if (iosBtn) iosBtn.classList.add("store-button--secondary");
    }

    return true;
  }

  function applyDevBadge(stores, lang) {
    var badge = document.getElementById("env-badge");
    if (!badge) return;
    badge.textContent = t(lang, "devBadge");
    badge.classList.toggle("is-visible", stores.showDevBadge);
  }

  function setMetaContent(selector, value) {
    var el = document.querySelector(selector);
    if (el) el.setAttribute("content", value);
  }

  function setLinkHref(selector, value) {
    var el = document.querySelector(selector);
    if (el) el.setAttribute("href", value);
  }

  function syncSocialMeta(lang, ml) {
    var origin = window.location.origin;
    var search = window.location.search || "";
    var pageUrl = origin + "/share" + search;
    var appName = t(lang, "appName");
    var title = ml
      ? formatMl(ml, lang) + " ml · " + appName
      : appName;
    var description = ml
      ? formatMl(ml, lang) + " ml — " + t(lang, "drankToday")
      : t(lang, "genericMessage");

    document.title = title;
    setMetaContent('meta[name="description"]', description);
    setMetaContent('meta[property="og:title"]', title);
    setMetaContent('meta[property="og:description"]', description);
    setMetaContent('meta[property="og:url"]', pageUrl);
    setMetaContent('meta[name="twitter:title"]', title);
    setMetaContent('meta[name="twitter:description"]', description);
    setLinkHref('link[rel="canonical"]', pageUrl);
  }

  function initSharePage() {
    var lang = detectLang();
    var env = detectEnv();
    var platform = detectPlatform();
    var stores = STORES[env] || STORES.prod;
    var ml = parseMl();

    document.documentElement.lang = lang === "uk" ? "uk" : "en";
    document.body.dataset.lang = lang;
    syncSocialMeta(lang, ml);

    setText("brand-title", t(lang, "appName"));
    setText("card-eyebrow", t(lang, "sharedProgress"));
    setText("card-subtitle", t(lang, "drankToday"));
    setText("card-message", ml ? t(lang, "sharedMessage") : t(lang, "genericMessage"));
    setText("cta-title", t(lang, "ctaTitle"));
    setText("qr-label", t(lang, "qrLabel"));
    setText("footer-note", t(lang, "footerInstalled"));
    applyDevBadge(stores, lang);

    var card = document.getElementById("share-card");
    var volumeEl = document.getElementById("card-volume");
    if (ml && volumeEl) {
      volumeEl.innerHTML =
        formatMl(ml, lang) + '<span class="card__unit">ml</span>';
    } else if (card) {
      card.classList.add("card--generic");
      setText("card-eyebrow", t(lang, "appName"));
    }

    applyStoreButtons(stores, platform, lang, env);

    var qrSection = document.getElementById("qr-section");
    var primaryUrl = pickStoreUrl(
      stores,
      platform === "desktop" ? "ios" : platform
    );

    if (qrSection && platform === "desktop" && primaryUrl) {
      qrSection.classList.add("is-visible");
      renderQrImage(document.getElementById("qr-image"), primaryUrl);
    }

    document.body.classList.add("is-ready");
  }

  function initHomePage() {
    var lang = detectLang();
    var env = detectEnv();
    var platform = detectPlatform();
    var stores = STORES[env] || STORES.prod;

    document.documentElement.lang = lang === "uk" ? "uk" : "en";
    document.body.dataset.lang = lang;
    document.title = t(lang, "appName");

    setText("brand-title", t(lang, "appName"));
    setText("hero-title", t(lang, "appName"));
    setText("hero-message", t(lang, "genericMessage"));
    applyDevBadge(stores, lang);
    applyStoreButtons(stores, platform, lang, env);
    document.body.classList.add("is-ready");
  }

  function setText(id, value) {
    var el = document.getElementById(id);
    if (el) el.textContent = value;
  }

  function boot() {
    if (document.body.dataset.page === "share") {
      initSharePage();
    } else if (document.body.dataset.page === "home") {
      initHomePage();
    }
  }

  if (document.readyState === "complete") {
    boot();
  } else {
    window.addEventListener("load", boot);
  }
})();
