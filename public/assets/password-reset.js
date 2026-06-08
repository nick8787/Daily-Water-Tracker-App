(function () {
  "use strict";

  var CONFIG = {
    dev: {
      apiKey: "AIzaSyDQrKegZ_sU5hAvPzCjuDU5MUmGaU7-wc0",
      authDomain: "dailywatertracker-app-dev.firebaseapp.com",
      projectId: "dailywatertracker-app-dev",
      showDevBadge: true,
    },
    prod: {
      apiKey: "AIzaSyAFINLbi3isX703H20NFIjIohCXozIunUU",
      authDomain: "dailywatertracker-app-prod.firebaseapp.com",
      projectId: "dailywatertracker-app-prod",
      showDevBadge: false,
    },
  };

  var I18N = {
    en: {
      devBadge: "Dev",
      loading: "Verifying reset link…",
      eyebrow: "Reset password",
      title: "Set a new password",
      subtitlePrefix: "Create a new password for",
      subtitleSuffix: ".",
      passwordLabel: "New password",
      passwordHint: "At least 6 characters",
      confirmLabel: "Confirm password",
      submit: "Save new password",
      successTitle: "Password updated",
      successMessage: "You can now sign in with your new password.",
      errorTitle: "Link not valid",
      errorInvalid: "This reset link is invalid or has already been used.",
      errorExpired: "This reset link has expired. Request a new one.",
      errorWeak: "Password is too weak. Use at least 6 characters.",
      errorMismatch: "Passwords do not match.",
      errorGeneric: "Could not update your password. Please try again.",
      footerInstalled:
        "Already have the app? Open this link on your phone — it will launch automatically.",
    },
    uk: {
      devBadge: "Dev",
      loading: "Перевірка посилання…",
      eyebrow: "Скидання пароля",
      title: "Новий пароль",
      subtitlePrefix: "Створіть новий пароль для",
      subtitleSuffix: ".",
      passwordLabel: "Новий пароль",
      passwordHint: "Щонайменше 6 символів",
      confirmLabel: "Підтвердіть пароль",
      submit: "Зберегти пароль",
      successTitle: "Пароль оновлено",
      successMessage: "Тепер можна увійти з новим паролем.",
      errorTitle: "Посилання недійсне",
      errorInvalid: "Посилання для скидання недійсне або вже використане.",
      errorExpired: "Термін дії посилання минув. Запросіть нове.",
      errorWeak: "Пароль занадто слабкий. Використайте щонайменше 6 символів.",
      errorMismatch: "Паролі не збігаються.",
      errorGeneric: "Не вдалося оновити пароль. Спробуйте ще раз.",
      footerInstalled:
        "Вже маєте застосунок? Відкрийте це посилання на телефоні — він запуститься автоматично.",
    },
  };

  function detectEnv() {
    var host = window.location.hostname || "";
    if (host.indexOf("-prod") !== -1) return "prod";
    return "dev";
  }

  function detectLang() {
    var lang = (navigator.language || "en").toLowerCase();
    if (lang.indexOf("uk") === 0) return "uk";
    return "en";
  }

  function getQueryParams() {
    return new URLSearchParams(window.location.search);
  }

  function readOobCode(params) {
    return (params.get("oobCode") || "").trim();
  }

  function readMode(params) {
    return (params.get("mode") || "").trim();
  }

  function showOnly(id) {
    ["loading-card", "form-card", "success-card", "error-card"].forEach(function (cardId) {
      var node = document.getElementById(cardId);
      if (!node) return;
      node.classList.toggle("hidden", cardId !== id);
    });
  }

  function setText(id, value) {
    var node = document.getElementById(id);
    if (node) node.textContent = value;
  }

  function mapVerifyError(code) {
    if (code === "auth/expired-action-code") return "errorExpired";
    if (code === "auth/invalid-action-code") return "errorInvalid";
    return "errorInvalid";
  }

  function mapSubmitError(code) {
    if (code === "auth/weak-password") return "errorWeak";
    if (code === "auth/expired-action-code") return "errorExpired";
    if (code === "auth/invalid-action-code") return "errorInvalid";
    return "errorGeneric";
  }

  function bindPasswordToggle(inputId, buttonId) {
    var input = document.getElementById(inputId);
    var button = document.getElementById(buttonId);
    if (!input || !button) return;

    button.addEventListener("click", function () {
      var isHidden = input.type === "password";
      input.type = isHidden ? "text" : "password";
    });
  }

  document.addEventListener("DOMContentLoaded", function () {
    var params = getQueryParams();
    var nestedLink = params.get("link");
    if (nestedLink) {
      var nestedParams = new URL(nestedLink, window.location.origin).searchParams;
      if (!params.get("oobCode") && nestedParams.get("oobCode")) {
        var redirectUrl = new URL(window.location.href);
        redirectUrl.pathname = "/password-reset";
        redirectUrl.search = nestedParams.toString();
        window.location.replace(redirectUrl.toString());
        return;
      }
    }

    var env = detectEnv();
    var lang = detectLang();
    var copy = I18N[lang];
    var settings = CONFIG[env];
    var params = getQueryParams();
    var oobCode = readOobCode(params);
    var mode = readMode(params);

    document.body.setAttribute("data-lang", lang === "uk" ? "uk" : "en");

    setText("brand-title", "Daily Water Tracker");
    setText("loading-message", copy.loading);
    setText("form-eyebrow", copy.eyebrow);
    setText("form-title", copy.title);
    setText("password-label", copy.passwordLabel);
    setText("password-hint", copy.passwordHint);
    setText("confirm-label", copy.confirmLabel);
    setText("submit-button", copy.submit);
    setText("success-title", copy.successTitle);
    setText("success-message", copy.successMessage);
    setText("error-title", copy.errorTitle);
    setText("footer-note", copy.footerInstalled);

    var badge = document.getElementById("env-badge");
    if (badge) {
      badge.textContent = copy.devBadge;
      badge.classList.toggle("hidden", !settings.showDevBadge);
    }

    bindPasswordToggle("new-password", "toggle-password");
    bindPasswordToggle("confirm-password", "toggle-confirm");

    if (!oobCode || (mode && mode !== "resetPassword")) {
      setText("error-message", copy.errorInvalid);
      showOnly("error-card");
      return;
    }

    firebase.initializeApp({
      apiKey: settings.apiKey,
      authDomain: settings.authDomain,
      projectId: settings.projectId,
    });

    var auth = firebase.auth();
    showOnly("loading-card");

    auth
      .verifyPasswordResetCode(oobCode)
      .then(function (email) {
        setText("account-email", email);
        var subtitle = document.getElementById("form-subtitle");
        if (subtitle) {
          subtitle.innerHTML =
            copy.subtitlePrefix +
            ' <span class="status-card__email" id="account-email">' +
            email +
            "</span>" +
            copy.subtitleSuffix;
        }
        showOnly("form-card");

        var form = document.getElementById("reset-form");
        var formError = document.getElementById("form-error");
        var submitButton = document.getElementById("submit-button");

        form.addEventListener("submit", function (event) {
          event.preventDefault();
          if (formError) formError.classList.add("hidden");

          var password = document.getElementById("new-password").value;
          var confirm = document.getElementById("confirm-password").value;

          if (password.length < 6) {
            if (formError) {
              formError.textContent = copy.errorWeak;
              formError.classList.remove("hidden");
            }
            return;
          }

          if (password !== confirm) {
            if (formError) {
              formError.textContent = copy.errorMismatch;
              formError.classList.remove("hidden");
            }
            return;
          }

          submitButton.disabled = true;

          auth
            .confirmPasswordReset(oobCode, password)
            .then(function () {
              showOnly("success-card");
            })
            .catch(function (error) {
              submitButton.disabled = false;
              if (formError) {
                formError.textContent = copy[mapSubmitError(error.code)] || copy.errorGeneric;
                formError.classList.remove("hidden");
              }
            });
        });
      })
      .catch(function (error) {
        setText("error-message", copy[mapVerifyError(error.code)] || copy.errorInvalid);
        showOnly("error-card");
      });
  });
})();
