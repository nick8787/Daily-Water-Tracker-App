(function () {
  "use strict";

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

  function appIconPath(env) {
    return env === "dev" ? "/assets/app-icon-dev.png" : "/assets/app-icon-prod.png";
  }

  function faviconPath(env) {
    return env === "dev" ? "/assets/favicon-dev.png" : "/assets/favicon-prod.png";
  }

  function setText(id, text) {
    var el = document.getElementById(id);
    if (el) {
      el.textContent = text;
    }
  }

  var COPY = {
    en: {
      appName: "Daily Water Tracker",
      devBadge: "Dev",
      pageTitle: "Privacy Policy",
      lastUpdated: "Last updated:",
      lastUpdatedDate: "January 6, 2025",
      intro:
        "This Privacy Policy describes how we collect, use, and protect your information when you use Daily Water Tracker and related services.\n\nWe use your data to provide hydration tracking, sync your progress across devices, send optional reminders, and improve app reliability — not for unrelated advertising.",
      collectTitle: "What we collect",
      collectItems: [
        "Account details you provide (such as email, display name, and profile photo) when you sign in or edit your profile.",
        "Hydration data you log (drink type, volume, date, and time) and derived statistics such as weekly activity.",
        "App preferences you set, including daily goal, drink presets, theme, and reminder schedule.",
        "Device notification permission status, used only if you enable reminders.",
        "Diagnostic and usage data (for example crash reports and anonymous analytics) to maintain security and fix issues.",
      ],
      useTitle: "How we use it",
      useItems: [
        "To store, display, and sync your hydration history and profile across your signed-in devices.",
        "To deliver optional hydration reminders you configure in the app.",
        "To calculate progress, statistics, achievements, and in-app insights.",
        "To operate the service, prevent abuse, and improve performance and stability.",
      ],
      sharingTitle: "Sharing & service providers",
      sharingItems: [
        "We use trusted infrastructure providers (such as Google Firebase for authentication, cloud storage, and analytics) that process data on our behalf under their own terms and security standards.",
        "We do not sell your personal information to third parties.",
      ],
      rightsTitle: "Your rights",
      rightsItems: [
        "You can delete your account and associated data from the app at any time (see Account → More).",
        "You may contact us to ask about your data or request correction where applicable.",
      ],
      contactTitle: "Contact",
      contactBody: "If you have questions about this policy, email us at:",
      backHome: "Back to home",
    },
    uk: {
      appName: "Daily Water Tracker",
      devBadge: "Dev",
      pageTitle: "Політика конфіденційності",
      lastUpdated: "Останнє оновлення:",
      lastUpdatedDate: "6 січня 2025 р.",
      intro:
        "Ця Політика конфіденційності описує, як ми збираємо, використовуємо та захищаємо вашу інформацію під час використання Daily Water Tracker та пов’язаних сервісів.\n\nМи використовуємо ваші дані для відстеження гідратації, синхронізації прогресу між пристроями, необов’язкових нагадувань і покращення надійності застосунку — не для сторонньої реклами.",
      collectTitle: "Що ми збираємо",
      collectItems: [
        "Дані облікового запису (email, ім’я, фото профілю), які ви надаєте під час входу або редагування профілю.",
        "Дані про гідратацію (тип напою, об’єм, дата, час) та похідну статистику, зокрема тижневу активність.",
        "Налаштування застосунку: денна ціль, пресети напоїв, тема, розклад нагадувань.",
        "Статус дозволу на сповіщення — лише якщо ви ввімкнули нагадування.",
        "Діагностичні та аналітичні дані (звіти про збої, анонімна аналітика) для безпеки та виправлення помилок.",
      ],
      useTitle: "Як ми це використовуємо",
      useItems: [
        "Для збереження, відображення та синхронізації історії гідратації й профілю на ваших пристроях.",
        "Для необов’язкових нагадувань про воду, які ви налаштовуєте в застосунку.",
        "Для розрахунку прогресу, статистики, досягнень і підказок у застосунку.",
        "Для роботи сервісу, запобігання зловживанням і покращення стабільності.",
      ],
      sharingTitle: "Передача даних і постачальники",
      sharingItems: [
        "Ми використовуємо надійну інфраструктуру (зокрема Google Firebase для автентифікації, хмарного сховища та аналітики), яка обробляє дані від нашого імені згідно з їхніми умовами та стандартами безпеки.",
        "Ми не продаємо вашу персональну інформацію третім сторонам.",
      ],
      rightsTitle: "Ваші права",
      rightsItems: [
        "Ви можете видалити обліковий запис і пов’язані дані в застосунку в будь-який час (Обліковий запис → Більше).",
        "Ви можете зв’язатися з нами щодо ваших даних або запиту на виправлення, де це застосовно.",
      ],
      contactTitle: "Контакти",
      contactBody: "Якщо у вас є питання щодо цієї політики, напишіть нам:",
      backHome: "На головну",
    },
  };

  var SUPPORT_EMAIL = "mykola.shchypailo@gmail.com";

  function renderList(id, items) {
    var list = document.getElementById(id);
    if (!list) {
      return;
    }
    list.innerHTML = "";
    items.forEach(function (item) {
      var li = document.createElement("li");
      li.textContent = item;
      list.appendChild(li);
    });
  }

  function init() {
    var lang = detectLang();
    var env = detectEnv();
    var copy = COPY[lang] || COPY.en;

    document.documentElement.lang = lang === "uk" ? "uk" : "en";
    document.body.setAttribute("data-lang", lang);

    document.title = copy.appName + " — " + copy.pageTitle;

    var iconPath = appIconPath(env);
    document.querySelectorAll("[data-app-icon]").forEach(function (img) {
      img.src = iconPath;
    });

    var favicon = document.querySelector('link[rel="icon"]');
    if (favicon) {
      favicon.href = faviconPath(env);
    }

    var badge = document.getElementById("env-badge");
    if (badge && env === "dev") {
      badge.textContent = copy.devBadge;
      badge.classList.add("is-visible");
    }

    setText("brand-title", copy.appName);
    setText("legal-title", copy.pageTitle);
    setText("last-updated-label", copy.lastUpdated);
    setText("last-updated-date", copy.lastUpdatedDate);
    setText("legal-intro", copy.intro);
    setText("section-collect-title", copy.collectTitle);
    setText("section-use-title", copy.useTitle);
    setText("section-sharing-title", copy.sharingTitle);
    setText("section-rights-title", copy.rightsTitle);
    setText("section-contact-title", copy.contactTitle);
    setText("contact-body", copy.contactBody);
    setText("back-home", copy.backHome);

    renderList("collect-list", copy.collectItems);
    renderList("use-list", copy.useItems);
    renderList("sharing-list", copy.sharingItems);
    renderList("rights-list", copy.rightsItems);

    var emailLink = document.getElementById("contact-email");
    if (emailLink) {
      emailLink.href = "mailto:" + SUPPORT_EMAIL;
      emailLink.textContent = SUPPORT_EMAIL;
    }
  }

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", init);
  } else {
    init();
  }
})();
