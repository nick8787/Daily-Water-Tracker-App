// DO NOT EDIT. This is code generated via package:easy_localization/generate.dart

// ignore_for_file: prefer_single_quotes, avoid_renaming_method_parameters, constant_identifier_names

import 'dart:ui';

import 'package:easy_localization/easy_localization.dart' show AssetLoader;

class CodegenLoader extends AssetLoader{
  const CodegenLoader();

  @override
  Future<Map<String, dynamic>?> load(String path, Locale locale) {
    return Future.value(mapLocales[locale.toString()]);
  }

  static const Map<String,dynamic> _uk_UA = {
  "app": {
    "title": "Трекер води"
  },
  "common": {
    "cancel": "Скасувати",
    "delete": "Видалити",
    "loading": "Завантаження…",
    "error": "Помилка",
    "retry": "Повторити",
    "em_dash": "—",
    "ml": "ml",
    "coming_soon": {
      "title": "Незабаром",
      "body": "{feature} ще недоступно."
    },
    "user_default": "Користувач"
  },
  "nav": {
    "statistics": "Статистика",
    "account": "Акаунт"
  },
  "loader": {
    "signing_in": "Вхід…",
    "creating_account": "Створення акаунта…",
    "saving": "Збереження…",
    "timeout": "Час очікування вичерпано. Спробуйте ще раз.",
    "preparing_share": "Підготовка посилання…",
    "deleting_account": "Видалення акаунта…",
    "updating_photo": "Оновлення фото…",
    "updating_password": "Оновлення пароля…",
    "loading_statistics": "Завантаження статистики…"
  },
  "auth": {
    "sign_in": {
      "title": "Увійти",
      "subtitle": "Увійдіть, щоб продовжити"
    },
    "sign_up": {
      "title": "Реєстрація",
      "subtitle": "Створіть акаунт, щоб продовжити"
    },
    "field": {
      "email": "Електронна пошта",
      "email_hint": "name@example.com",
      "password": "Пароль",
      "confirm_password": "Підтвердіть пароль"
    },
    "button": {
      "sign_in": "Увійти",
      "create_account": "Створити акаунт"
    },
    "divider": {
      "or": "або"
    },
    "link": {
      "no_account": "Немає акаунта?",
      "sign_up": "Зареєструватися",
      "have_account": "Вже є акаунт?"
    },
    "social": {
      "google": "Увійти через Google",
      "facebook": "Увійти через Facebook",
      "apple": "Увійти через Apple"
    },
    "validation": {
      "email_required": "Вкажіть електронну пошту.",
      "email_invalid": "Введіть коректну адресу.",
      "password_required": "Вкажіть пароль.",
      "password_min_length": "Щонайменше 6 символів.",
      "confirm_password_required": "Підтвердіть пароль.",
      "passwords_mismatch": "Паролі не збігаються."
    },
    "error": {
      "generic": "Щось пішло не так. Спробуйте ще раз.",
      "sign_in_cancelled": "Вхід скасовано.",
      "invalid_email": "Некоректний формат email.",
      "invalid_credentials": "Невірний email або пароль.",
      "account_disabled": "Ваш акаунт вимкнено.",
      "too_many_requests": "Забагато спроб. Спробуйте пізніше.",
      "network": "Помилка мережі. Перевірте з'єднання.",
      "email_in_use": "Цей email уже використовується.",
      "weak_password": "Пароль занадто слабкий.",
      "signup_not_allowed": "Реєстрація email/пароль не увімкнена.",
      "credential_conflict": "Цей email уже прив'язаний до іншого способу входу.",
      "facebook_failed": "Не вдалося увійти через Facebook. Спробуйте ще раз.",
      "apple_ios_only": "Вхід через Apple доступний лише на iOS.",
      "google_misconfigured": "Google Sign-In налаштовано некоректно: немає ID token. Перевірте SHA-1/SHA-256 та config-файли.",
      "apple_misconfigured": "Apple Sign-In налаштовано некоректно: немає identity token. Увімкніть Sign in with Apple та провайдер у Firebase.",
      "google_api_10": "Google Sign-In (ApiException: 10). Перевірте SHA-1/SHA-256 у Firebase та google-services.json.",
      "google_emulator": "Не вдалося увійти через Google. На емуляторі потрібні Google Play Services та акаунт Google.",
      "google_failed": "Не вдалося увійти через Google: {error}",
      "facebook_failed_dynamic": "Не вдалося увійти через Facebook: {error}",
      "apple_failed_dynamic": "Не вдалося увійти через Apple: {error}",
      "auth_failed": "Помилка автентифікації.",
      "signup_failed": "Не вдалося зареєструватися."
    }
  },
  "drink_type": {
    "water": "Вода",
    "coffee": "Кава",
    "green_tea": "Зелений чай",
    "milk": "Молоко"
  },
  "home": {
    "empty": {
      "today": "Сьогодні напоїв\nще немає",
      "other_day": "За цей день\nнапоїв немає"
    },
    "progress": {
      "done": "випито",
      "of_goal": "з {goal} ml"
    },
    "today_drinks": {
      "title": "Напої сьогодні:"
    },
    "toggle": {
      "overall_volume": "Загальний об'єм",
      "todays_drinks": "Напої сьогодні"
    },
    "tooltip": {
      "info": "Інфо",
      "previous_day": "Попередній день",
      "next_day": "Наступний день"
    },
    "semantics": {
      "selected_day": "Обраний день {weekday} {date}",
      "choose_date": "Обрати дату"
    },
    "row": {
      "coefficient": "коефіцієнт {value}",
      "volume_ml": "{volume} ml"
    },
    "sheet": {
      "add": {
        "title": "Додати напій"
      },
      "edit": {
        "title": "Редагувати напій"
      },
      "hydration_coefficient": "Коефіцієнт гідратації ×{coeff}",
      "quick_presets": "Швидкі пресети",
      "manual_entry": "Вручну",
      "hint_volume": "напр. 175",
      "preset_ml": "{value} ml",
      "button": {
        "add": "Додати",
        "save_changes": "Зберегти",
        "delete_entry": "Видалити запис"
      },
      "nudge_ml": "+{amount}"
    },
    "error": {
      "invalid_amount": "Введіть коректну кількість у мілілітрах.",
      "amount_too_large": "Занадто багато (макс. {max} ml).",
      "add_failed_code": "Не вдалося додати: {code}",
      "add_failed": "Не вдалося додати запис. Спробуйте ще раз."
    },
    "success": {
      "added_title": "{drink} додано!",
      "added_message": "{ml} ml × {coeff} коеф. = {effective} ml зараховано до цілі."
    },
    "dialog": {
      "delete": {
        "title": "Видалити запис?",
        "message": "Напій буде видалено з журналу за цей день. Цю дію не можна скасувати."
      }
    },
    "snackbar": {
      "save_failed": "Не вдалося зберегти",
      "delete_failed": "Не вдалося видалити"
    }
  },
  "hydration_info": {
    "title": "Індекс гідратації",
    "subtitle": "Як напій зараховується до цілі",
    "formula": {
      "volume": "Об'єм",
      "coefficient": "Коефіцієнт",
      "hydration": "Гідратація"
    },
    "example": "Приклад: 300 ml × 0,8 = 240 ml зараховано до денної цілі.",
    "defaults_title": "Типові коефіцієнти",
    "body": "Чиста вода — повна сила (1,0). Інші напої мають коефіцієнт, щоб кільце прогресу відображало ефективну гідратацію."
  },
  "account": {
    "title": "Акаунт",
    "tooltip": {
      "debug": "Debug"
    },
    "menu": {
      "my_profile": "Мій профіль",
      "preferences": "Денна ціль / налаштування",
      "history": "Історія",
      "notifications": "Сповіщення",
      "share_progress": "Поділитися прогресом",
      "login_security": "Вхід і безпека",
      "privacy_policy": "Політика конфіденційності",
      "dark_theme": "Темна тема",
      "more": "Ще",
      "achievements": "Мої досягнення"
    },
    "photo": {
      "sheet_title": "Фото профілю",
      "gallery": "Обрати з галереї",
      "camera": "Зробити фото",
      "remove": "Прибрати фото"
    },
    "button": {
      "delete": "Видалити",
      "log_out": "Вийти"
    },
    "dialog": {
      "logout": {
        "title": "Вийти?",
        "message": "Потрібно буде знову увійти, щоб отримати доступ до даних.",
        "confirm": "Вийти"
      },
      "delete": {
        "title": "Видалити акаунт?",
        "message": "Це назавжди видалить профіль, історію та збережені фото. Скасувати неможливо.",
        "confirm": "Видалити акаунт"
      }
    },
    "snackbar": {
      "nothing_to_share": {
        "title": "Немає чим ділитися",
        "message": "Сьогодні ще немає записів."
      },
      "share_failed": "Не вдалося поділитися. Спробуйте ще раз.",
      "sign_out_failed": "Не вдалося вийти. Спробуйте ще раз.",
      "delete_failed": "Не вдалося видалити акаунт. Спробуйте ще раз."
    },
    "success": {
      "title": "Готово",
      "photo_updated": "Фото профілю оновлено",
      "photo_removed": "Фото профілю видалено"
    },
    "error": {
      "not_authenticated": "Користувач не автентифікований",
      "photo_upload": "Не вдалося завантажити фото. Спробуйте пізніше.",
      "photo_remove": "Не вдалося видалити фото. Спробуйте пізніше."
    },
    "overlay": {
      "signing_out": "Вихід…"
    },
    "deletion": {
      "not_signed_in": "Ви не увійшли в акаунт.",
      "recent_login": "З міркувань безпеки увійдіть знову та повторіть видалення."
    }
  },
  "login_security": {
    "title": "Вхід і безпека",
    "change_password": "Змінити пароль",
    "change_password_title": "Змінити пароль",
    "field": {
      "old_password": "Ваш старий пароль",
      "new_password": "Ваш новий пароль",
      "old_password_hint": "Введіть поточний пароль",
      "new_password_hint": "Щонайменше 6 символів"
    },
    "button": {
      "save_changes": "Зберегти зміни"
    },
    "success": {
      "title": "Готово",
      "message": "Пароль успішно оновлено."
    },
    "snackbar": {
      "email_only_title": "Недоступно",
      "email_only": "Зміна пароля доступна лише для email-акаунтів."
    },
    "error": {
      "not_signed_in": "Ви не увійшли в акаунт.",
      "wrong_password": "Невірний поточний пароль.",
      "recent_login": "З міркувань безпеки увійдіть знову та повторіть зміну пароля.",
      "generic": "Не вдалося оновити пароль. Спробуйте ще раз."
    }
  },
  "profile": {
    "title": "Мій профіль",
    "avatar": {
      "fallback": "Профіль"
    },
    "section": {
      "personal": "Особисті дані",
      "physical": "Фізичні параметри",
      "stats": "Статистика профілю"
    },
    "field": {
      "full_name": "Повне ім'я",
      "email": "Email",
      "weight": "Вага (кг)",
      "gender": "Стать"
    },
    "validation": {
      "required": "Обов'язкове поле",
      "weight_invalid": "Некоректно",
      "weight_positive": "> 0",
      "weight_too_large": "Занадто багато"
    },
    "tip": {
      "auto_goal": "Порада: пізніше можна рахувати ціль як ~30 ml на 1 кг."
    },
    "gender": {
      "select": "Обрати",
      "male": "Чоловіча",
      "female": "Жіноча",
      "other": "Інше"
    },
    "stats": {
      "member_since": "У системі з",
      "total_days": "Днів із записами"
    },
    "button": {
      "save": "Зберегти"
    },
    "snackbar": {
      "saved": {
        "title": "Збережено",
        "message": "Дані профілю збережено."
      }
    },
    "error": {
      "save_failed": "Не вдалося зберегти профіль. Спробуйте ще раз.",
      "upload_photo": "Не вдалося завантажити фото."
    }
  },
  "preferences": {
    "title": "Денна ціль",
    "section": {
      "goal": "Денна ціль гідратації",
      "presets": "Пресети напоїв",
      "reminders": "Нагадування"
    },
    "goal": {
      "hint": "Перетягніть, щоб задати ціль",
      "auto_toggle": "Рахувати від ваги (~{mlPerKg} ml на кг)",
      "auto_hint": "Ціль залежить від ваги в профілі. Вимкніть для ручного налаштування.",
      "value_ml": "{value} ml"
    },
    "presets": {
      "hint": "Налаштуйте кнопки швидкого додавання"
    },
    "reminders": {
      "hint": "Нагадування допоможуть пити воду протягом дня",
      "interval_label": "Інтервал нагадувань",
      "off": "Вимкнено",
      "every_1h": "Кожну 1 годину",
      "every_2h": "Кожні 2 години",
      "every_3h": "Кожні 3 години",
      "every_4h": "Кожні 4 години",
      "debug_3min": "Кожні 3 хвилини (DEBUG)",
      "quiet_hours": "Тихі години (не турбувати)",
      "from": "З",
      "to": "До"
    },
    "button": {
      "save": "Зберегти"
    },
    "snackbar": {
      "title": "Налаштування",
      "saved": {
        "title": "Збережено",
        "message": "Налаштування збережено."
      },
      "set_weight_first": "Спочатку вкажіть вагу в «Мій профіль»."
    },
    "error": {
      "save_failed": "Не вдалося зберегти. Спробуйте ще раз."
    },
    "info": {
      "goal": {
        "title": "Денна ціль гідратації",
        "why_title": "Навіщо це",
        "why_body": "Гідратація підтримує енергію, концентрацію та самопочуття. Денна ціль — дружня орієнтир для звички, а не медична рекомендація.",
        "auto_title": "Авто від ваги",
        "auto_prefix": "Якщо увімкнено, оцінюємо ціль як ",
        "auto_formula": "вага (кг) × 35 ml",
        "auto_suffix": ", потім округлюємо до 50 ml для зручного слайдера. Типовий орієнтир у багатьох застосунках.",
        "control_bold": "Ви керуєте: ",
        "control_body": "вимкніть авто та підлаштуйте слайдер під себе."
      },
      "presets": {
        "title": "Пресети напоїв",
        "quick_title": "Кнопки швидкого додавання",
        "quick_body": "Три улюблені об'єми для швидкого логування — ті самі чіпи на головному екрані.",
        "tune_prefix": "Підлаштуйте під ",
        "tune_bold": "ваші чашки та пляшки",
        "tune_suffix": ". Наприклад, 250 ml для чашки чаю або 750 ml для пляшки в залі — один дотик замість вводу.",
        "tip": "Порада: оберіть реальні округлені значення — так трекінг стане легшим."
      },
      "reminders": {
        "title": "Нагадування",
        "gentle_title": "М'які нагадування",
        "gentle_body": "Допомагають пити протягом дня, а не наздоганяти ввечері. Оберіть інтервал або вимкніть на тихий день.",
        "quiet_title": "Тихі години (не турбувати)",
        "quiet_body": "Вікно, коли застосунок мовчить — наприклад, вночі. Поза ним нагадування працюють за інтервалом.",
        "quiet_note": "Тихі години лише коли нагадування увімкнені. Якщо «Вимкнено» — інтервальних push не буде."
      }
    }
  },
  "statistics": {
    "title": "Статистика",
    "error": {
      "load_failed": "Не вдалося завантажити статистику. Потягніть, щоб оновити."
    },
    "weekly_activity": {
      "title": "Тижнева активність"
    },
    "chart": {
      "goal_label": "ЦІЛЬ",
      "goal_reached": "Ціль досягнута! 🎉",
      "ml_left": "залишилось {remain} ml"
    },
    "footer": {
      "no_goal": "Задайте денну ціль у налаштуваннях, щоб бачити прогрес по днях.",
      "default": "Кожен стовпчик — день. Тримайте ритм!"
    },
    "breakdown": {
      "title": "Розподіл споживання",
      "caption": "Останні 7 днів · ефективна гідратація",
      "empty": "Додавайте напої, щоб побачити розподіл за типами.",
      "scroll_hint": "Прокрутіть для більшого"
    },
    "period": {
      "last_7_days": "Останні 7 днів"
    },
    "insights": {
      "title": "Інсайти тижня",
      "best_day": "Найкращий день",
      "best_day_subtitle": "Найбільше гідратації",
      "streak": "Поточна серія",
      "streak_zero": "0 днів",
      "streak_days_one": "1 день 🔥",
      "streak_days_other": "{count} днів 🔥",
      "no_goal": "Задайте ціль для серій",
      "start_streak": "Досягніть цілі, щоб почати",
      "goal_met_today": "Ціль сьогодні досягнута"
    }
  },
  "history": {
    "title": "Історія",
    "button": {
      "go_back": "Назад"
    },
    "day": {
      "today": "Сьогодні",
      "yesterday": "Вчора"
    },
    "error": {
      "load_failed": "Не вдалося завантажити історію."
    },
    "empty": {
      "title": "Записів ще немає",
      "body": "Почніть пити воду — кожна чашка має значення.\nТут з'явиться ваша історія гідратації."
    }
  },
  "app_update": {
    "title": "Потрібне оновлення",
    "message": "Оновіть застосунок до останньої версії",
    "button": {
      "android": "Оновити зараз",
      "ios": "Оновити"
    }
  },
  "debug": {
    "title": "Debug",
    "section": {
      "device_id": "DEVICE ID",
      "subscriptions": "SUBSCRIPTIONS",
      "reminders": "REMINDERS STATUS"
    },
    "locale": {
      "en": "EN",
      "uk": "UK",
      "sys": "SYS"
    },
    "fcm": {
      "title": "FCM Token",
      "no_token": "Токен не згенеровано",
      "copied": {
        "title": "Скопійовано",
        "message": "FCM токен скопійовано"
      }
    },
    "topic": {
      "title": "Тема: reminder",
      "subscribed": "Підписано",
      "not_subscribed": "Не підписано"
    },
    "reminders": {
      "next": "Наступне нагадування",
      "none": "Немає",
      "updating": "Оновлення…",
      "countdown": "через {minutes} хв {seconds} с",
      "reset": "Скинути й перепланувати",
      "test_button": "Тестовий push зараз",
      "refreshed": "Розклад оновлено з поточного моменту.",
      "test_title": "Тестовий push",
      "test_sent": "Надіслано.",
      "test_failed": "Тестовий push не вдався: {error}"
    }
  },
  "notifications": {
    "dialog": {
      "title": "Увімкніть сповіщення",
      "body": "Нагадування потребують дозволу на сповіщення. Увімкніть у системних налаштуваннях.",
      "not_now": "Не зараз",
      "open_settings": "Відкрити налаштування"
    }
  },
  "main_nav": {
    "coming_soon": {
      "add_drink": "Додати напій"
    }
  },
  "deep_link": {
    "shared": {
      "title": "Спільна гідратація",
      "drank_today": "випито сьогодні",
      "message": "Друг поділився своїм денним прогресом гідратації з тобою.",
      "primary_action": "Відстежувати і свій прогрес",
      "secondary_action": "Можливо пізніше"
    },
    "share": {
      "progress_message": "Сьогодні я випив(ла) {ml} мл у Daily Water Tracker. Відстежуй і свій прогрес:\n{url}"
    }
  },
  "language": {
    "english": "English",
    "ukrainian": "Українська"
  },
  "reminder": {
    "msg_01": {
      "title": "Твоє тіло — храм! 🏛️",
      "body": "Йому зараз потрібна крапля води. Зроби ковток! 💧"
    },
    "msg_02": {
      "title": "Заряд фокусу! ⚡",
      "body": "Втома? Можливо, бракує води. Випий! 🥤"
    },
    "msg_03": {
      "title": "Перерва на воду! ⏲️",
      "body": "Відійди від екрана й випий води 🌊"
    },
    "msg_04": {
      "title": "Маленький ковток — велика перемога ⭐",
      "body": "Навіть склянка має значення 🥛"
    },
    "msg_05": {
      "title": "Чекпоінт гідратації 📍",
      "body": "Коли останній раз пив воду? Зараз чудовий момент ✅"
    },
    "msg_06": {
      "title": "Паливо для енергії ✨",
      "body": "Вода допомагає шкірі та тонусу. Налий склянку! 🔋"
    },
    "msg_07": {
      "title": "Прогулянка до кухні 🚶‍♂️",
      "body": "Розімни ноги й наповни пляшку 🚰"
    },
    "msg_08": {
      "title": "Патруль ясності 🧠",
      "body": "Ковток води може прояснити думки. Спробуй! 💡"
    },
    "msg_09": {
      "title": "Чіпляємо за тебе! 🥂",
      "body": "Ти будуєш здорову звичку. Дружнє нагадування випити 😊"
    },
    "msg_10": {
      "title": "Режим рослини 🌿",
      "body": "Ти поливаєш квіти — полий і себе. Гідратуйся! 🚿"
    },
    "msg_11": {
      "title": "Ковток сили 💪",
      "body": "Підтримай темп свіжою водою ⛲"
    },
    "msg_12": {
      "title": "Добре нагадування 💙",
      "body": "Без тиску — м'яке запрошення випити води 🌊"
    }
  },
  "legal": {
    "privacy_policy": {
      "title": "Політика конфіденційності",
      "last_updated_label": "Останнє оновлення:",
      "last_updated_date": "6 червня 2026 р.",
      "intro": "Ця Політика конфіденційності описує, як ми збираємо, використовуємо та захищаємо вашу інформацію під час користування Daily Water Tracker і пов’язаними сервісами.\n\nМи використовуємо ваші дані для обліку гідратації, синхронізації прогресу між пристроями, необов’язкових нагадувань і покращення стабільності застосунку — не для сторонньої реклами.",
      "section_collect": "Що ми збираємо",
      "collect_account": "Дані облікового запису, які ви надаєте (наприклад, email, ім’я та фото профілю) під час входу або редагування профілю.",
      "collect_hydration": "Дані про гідратацію, які ви вносите (тип напою, об’єм, дата та час), а також похідну статистику, зокрема тижневу активність.",
      "collect_preferences": "Налаштування застосунку: денна ціль, пресети напоїв, тема та розклад нагадувань.",
      "collect_notifications": "Статус дозволу на сповіщення — лише якщо ви увімкнули нагадування.",
      "collect_diagnostics": "Діагностичні та анонімні дані використання (наприклад, звіти про збої та аналітика) для безпеки та виправлення помилок.",
      "section_use": "Як ми це використовуємо",
      "use_sync": "Для збереження, відображення та синхронізації історії гідратації й профілю між вашими пристроями.",
      "use_reminders": "Для необов’язкових нагадувань про воду, які ви налаштовуєте в застосунку.",
      "use_insights": "Для розрахунку прогресу, статистики, досягнень та підказок у застосунку.",
      "use_improve": "Для роботи сервісу, запобігання зловживанням і покращення продуктивності та стабільності.",
      "section_sharing": "Передача даних і постачальники",
      "sharing_processors": "Ми користуємося надійною інфраструктурою (зокрема Google Firebase для автентифікації, хмарного сховища та аналітики), яка обробляє дані від нашого імені згідно з власними умовами та стандартами безпеки.",
      "sharing_no_sell": "Ми не продаємо вашу персональну інформацію третім особам.",
      "section_rights": "Ваші права",
      "rights_delete": "Ви можете видалити обліковий запис і пов’язані дані в застосунку будь-коли (Обліковий запис → Ще).",
      "rights_contact": "Ви можете зв’язатися з нами, щоб дізнатися про свої дані або запросити їх виправлення, де це застосовно.",
      "section_contact": "Контакти",
      "contact_body": "Якщо у вас є запитання щодо цієї політики, напишіть нам:",
      "contact_email": "mykola.shchypailo@gmail.com"
    }
  },
  "achievements": {
    "loading": "Завантажуємо досягнення…",
    "error_load_failed": "Не вдалося завантажити досягнення. Спробуйте ще раз.",
    "banner_current_rank": "Ваш ранг: {rank}",
    "banner_achieved_rank_label": "Досягнутий ранг",
    "banner_no_rank": "Ваш ранг: Початківець (ще не розблоковано)",
    "banner_no_rank_title": "Ще не розблоковано",
    "status_locked": "Заблоковано",
    "status_locked_hint": "Досягніть попереднього рангу та виконайте умови",
    "status_unlocked": "Ранг досягнуто!",
    "ranks": {
      "beginner": {
        "title": "Початківець",
        "desc": "Запишіть свій перший склянку води."
      },
      "fan": {
        "title": "Водяний ентузіаст",
        "desc": "Виконайте денну ціль 7 днів (не обов'язково підряд)."
      },
      "master": {
        "title": "Аква-Майстер",
        "desc": "30 днів з виконаною ціллю та 50 літрів води."
      },
      "ocean_lord": {
        "title": "Володар Океану",
        "desc": "100 днів з ціллю та 200 літрів води."
      },
      "poseidon": {
        "title": "Аква-Посейдон",
        "desc": "365 днів з ціллю та 700 літрів води."
      }
    },
    "conditions": {
      "first_log": "Перший запис води",
      "goal_days": "Днів з виконаною ціллю",
      "total_volume": "Загальний об'єм гідратації"
    },
    "celebration": {
      "barrier_label": "Святкування рангу",
      "congrats": "ВІТАЄМО!",
      "new_status": "Ваш новий статус:",
      "primary_action": "Ура!",
      "share": "Поділитися",
      "share_message": "Я досяг(ла) рангу {rank} у Daily Water Tracker! Сьогодні випив(ла) {ml} мл.\n{url}",
      "title": "Новий ранг розблоковано!",
      "continue": "Продовжити",
      "teaser_next_rank_title": "Клас!",
      "teaser_next_rank_message": "Наступна ціль: {rank}. Продовжуй в тому ж дусі!",
      "teaser_max_rank_title": "Легенда гідратації!",
      "teaser_max_rank_message": "Ви досягли абсолютної вершини. Так тримати!"
    }
  }
};
static const Map<String,dynamic> _en_US = {
  "app": {
    "title": "Daily Water Tracker"
  },
  "common": {
    "cancel": "Cancel",
    "delete": "Delete",
    "loading": "Loading…",
    "error": "Error",
    "retry": "Retry",
    "em_dash": "—",
    "ml": "ml",
    "coming_soon": {
      "title": "Coming soon",
      "body": "{feature} is not available yet."
    },
    "user_default": "User"
  },
  "nav": {
    "statistics": "Statistics",
    "account": "Account"
  },
  "loader": {
    "signing_in": "Signing in…",
    "creating_account": "Creating account…",
    "saving": "Saving…",
    "timeout": "Request timed out. Please try again.",
    "preparing_share": "Preparing share link…",
    "deleting_account": "Deleting account…",
    "updating_photo": "Updating profile photo…",
    "updating_password": "Updating password…",
    "loading_statistics": "Loading statistics…"
  },
  "auth": {
    "sign_in": {
      "title": "Sign In",
      "subtitle": "Please sign in to continue"
    },
    "sign_up": {
      "title": "Sign Up",
      "subtitle": "Create an account to continue"
    },
    "field": {
      "email": "Email",
      "email_hint": "name@example.com",
      "password": "Password",
      "confirm_password": "Confirm password"
    },
    "button": {
      "sign_in": "Sign In",
      "create_account": "Create account"
    },
    "divider": {
      "or": "or"
    },
    "link": {
      "no_account": "Don't have an account?",
      "sign_up": "Sign Up",
      "have_account": "Already have an account?"
    },
    "social": {
      "google": "Continue with Google",
      "facebook": "Continue with Facebook",
      "apple": "Continue with Apple"
    },
    "validation": {
      "email_required": "Email is required.",
      "email_invalid": "Enter a valid email.",
      "password_required": "Password is required.",
      "password_min_length": "At least 6 characters.",
      "confirm_password_required": "Confirm your password.",
      "passwords_mismatch": "Passwords do not match."
    },
    "error": {
      "generic": "Something went wrong. Please try again.",
      "sign_in_cancelled": "Sign-in cancelled.",
      "invalid_email": "Invalid email format.",
      "invalid_credentials": "Invalid email or password.",
      "account_disabled": "Your account is disabled.",
      "too_many_requests": "Too many attempts. Try again later.",
      "network": "Network error. Check your connection.",
      "email_in_use": "This email is already in use.",
      "weak_password": "Password is too weak.",
      "signup_not_allowed": "Email/password sign up is not enabled.",
      "credential_conflict": "This email is already used with another sign-in method.",
      "facebook_failed": "Facebook sign-in failed. Please try again.",
      "apple_ios_only": "Apple Sign-In is only available on iOS.",
      "google_misconfigured": "Google Sign-In misconfigured: missing ID token. Recheck SHA-1/SHA-256 and downloaded config files.",
      "apple_misconfigured": "Apple Sign-In misconfigured: missing identity token. Ensure Sign in with Apple capability is enabled and Apple provider is configured in Firebase.",
      "google_api_10": "Google Sign-In misconfigured (ApiException: 10). Check SHA-1/SHA-256 in Firebase + google-services.json.",
      "google_emulator": "Google sign-in failed. On emulator, ensure Google Play services and a Google account are available.",
      "google_failed": "Google sign-in failed: {error}",
      "facebook_failed_dynamic": "Facebook sign-in failed: {error}",
      "apple_failed_dynamic": "Apple sign-in failed: {error}",
      "auth_failed": "Authentication failed.",
      "signup_failed": "Sign up failed."
    }
  },
  "drink_type": {
    "water": "Water",
    "coffee": "Coffee",
    "green_tea": "Green tea",
    "milk": "Milk"
  },
  "home": {
    "empty": {
      "today": "No drinks added\ntoday",
      "other_day": "No drinks added\nfor this day"
    },
    "progress": {
      "done": "done",
      "of_goal": "of {goal} ml"
    },
    "today_drinks": {
      "title": "Today's drinks:"
    },
    "toggle": {
      "overall_volume": "Overall volume",
      "todays_drinks": "Today's drinks"
    },
    "tooltip": {
      "info": "Info",
      "previous_day": "Previous day",
      "next_day": "Next day"
    },
    "semantics": {
      "selected_day": "Selected day {weekday} {date}",
      "choose_date": "Choose date"
    },
    "row": {
      "coefficient": "coefficient {value}",
      "volume_ml": "{volume} ml"
    },
    "sheet": {
      "add": {
        "title": "Add drink"
      },
      "edit": {
        "title": "Edit drink"
      },
      "hydration_coefficient": "Hydration coefficient ×{coeff}",
      "quick_presets": "Quick presets",
      "manual_entry": "Manual entry",
      "hint_volume": "e.g. 175",
      "preset_ml": "{value} ml",
      "button": {
        "add": "Add",
        "save_changes": "Save changes",
        "delete_entry": "Delete entry"
      },
      "nudge_ml": "+{amount}"
    },
    "error": {
      "invalid_amount": "Enter a valid amount in milliliters.",
      "amount_too_large": "Amount too large (max {max} ml).",
      "add_failed_code": "Unable to add record: {code}",
      "add_failed": "Unable to add record. Try again."
    },
    "success": {
      "added_title": "{drink} added!",
      "added_message": "{ml} ml × {coeff} coeff = {effective} ml added to your goal."
    },
    "dialog": {
      "delete": {
        "title": "Delete entry?",
        "message": "This drink will be removed from your log for this day. This cannot be undone."
      }
    },
    "snackbar": {
      "save_failed": "Could not save changes",
      "delete_failed": "Could not delete"
    }
  },
  "hydration_info": {
    "title": "Hydration index",
    "subtitle": "How your drink counts toward the goal",
    "formula": {
      "volume": "Volume",
      "coefficient": "Coefficient",
      "hydration": "Hydration"
    },
    "example": "Example: 300 ml × 0.8 = 240 ml counted toward your daily target.",
    "defaults_title": "Default coefficients",
    "body": "Plain water hydrates at full strength (1.0). Other drinks use a coefficient so your progress ring reflects effective hydration, not just volume."
  },
  "account": {
    "title": "Account",
    "tooltip": {
      "debug": "Debug"
    },
    "menu": {
      "my_profile": "My Profile",
      "preferences": "Daily goal / preferences",
      "history": "History",
      "notifications": "Notifications",
      "share_progress": "Share today's progress",
      "login_security": "Login & security",
      "privacy_policy": "Privacy policy",
      "dark_theme": "Use dark theme",
      "more": "More",
      "achievements": "Achievements"
    },
    "photo": {
      "sheet_title": "Profile photo",
      "gallery": "Choose from gallery",
      "camera": "Take a photo",
      "remove": "Remove photo"
    },
    "button": {
      "delete": "Delete",
      "log_out": "Log out"
    },
    "dialog": {
      "logout": {
        "title": "Log out?",
        "message": "You will need to sign in again to access your data.",
        "confirm": "Log out"
      },
      "delete": {
        "title": "Delete account?",
        "message": "This permanently deletes your profile, history, and stored photos. This cannot be undone.",
        "confirm": "Delete account"
      }
    },
    "snackbar": {
      "nothing_to_share": {
        "title": "Nothing to share",
        "message": "No drinks logged for today yet."
      },
      "share_failed": "Unable to share progress. Try again.",
      "sign_out_failed": "Could not sign out. Please try again.",
      "delete_failed": "Could not delete your account. Please try again."
    },
    "success": {
      "title": "Success",
      "photo_updated": "Profile photo updated successfully",
      "photo_removed": "Profile photo removed successfully"
    },
    "error": {
      "not_authenticated": "User not authenticated",
      "photo_upload": "Failed to upload photo. Please try again later.",
      "photo_remove": "Failed to remove photo. Please try again later."
    },
    "overlay": {
      "signing_out": "Signing out…"
    },
    "deletion": {
      "not_signed_in": "You are not signed in.",
      "recent_login": "For security, sign in again and retry deleting your account."
    }
  },
  "login_security": {
    "title": "Login & security",
    "change_password": "Change password",
    "change_password_title": "Change password",
    "field": {
      "old_password": "Your old password",
      "new_password": "Your new password",
      "old_password_hint": "Enter your current password",
      "new_password_hint": "At least 6 characters"
    },
    "button": {
      "save_changes": "Save changes"
    },
    "success": {
      "title": "Success",
      "message": "Password updated successfully."
    },
    "snackbar": {
      "email_only_title": "Not available",
      "email_only": "Password change is only available for email accounts."
    },
    "error": {
      "not_signed_in": "You are not signed in.",
      "wrong_password": "Incorrect current password.",
      "recent_login": "For security, sign in again and retry changing your password.",
      "generic": "Could not update password. Please try again."
    }
  },
  "profile": {
    "title": "My Profile",
    "avatar": {
      "fallback": "Profile"
    },
    "section": {
      "personal": "Personal details",
      "physical": "Physical parameters",
      "stats": "Profile stats"
    },
    "field": {
      "full_name": "Full name",
      "email": "Email",
      "weight": "Weight (kg)",
      "gender": "Gender"
    },
    "validation": {
      "required": "Required field",
      "weight_invalid": "Invalid",
      "weight_positive": "> 0",
      "weight_too_large": "Too large"
    },
    "tip": {
      "auto_goal": "Tip: later we can calculate daily goal as ~30 ml per 1 kg."
    },
    "gender": {
      "select": "Select",
      "male": "Male",
      "female": "Female",
      "other": "Other"
    },
    "stats": {
      "member_since": "Member since",
      "total_days": "Total days"
    },
    "button": {
      "save": "Save"
    },
    "snackbar": {
      "saved": {
        "title": "Saved",
        "message": "Profile details saved."
      }
    },
    "error": {
      "save_failed": "Failed to save profile. Please try again.",
      "upload_photo": "Failed to upload photo."
    }
  },
  "preferences": {
    "title": "Daily goal",
    "section": {
      "goal": "Daily hydration goal",
      "presets": "Drink presets",
      "reminders": "Reminders"
    },
    "goal": {
      "hint": "Drag to set your target intake",
      "auto_toggle": "Calculate based on my weight (~{mlPerKg} ml per kg)",
      "auto_hint": "Goal follows your profile weight. Turn off to adjust manually.",
      "value_ml": "{value} ml"
    },
    "presets": {
      "hint": "Configure your quick-add buttons"
    },
    "reminders": {
      "hint": "Stay on track with hydration reminders",
      "interval_label": "Reminder interval",
      "off": "Off",
      "every_1h": "Every 1 hour",
      "every_2h": "Every 2 hours",
      "every_3h": "Every 3 hours",
      "every_4h": "Every 4 hours",
      "debug_3min": "Every 3 minutes (DEBUG)",
      "quiet_hours": "Quiet hours (Do not disturb)",
      "from": "From",
      "to": "To"
    },
    "button": {
      "save": "Save"
    },
    "snackbar": {
      "title": "Preferences",
      "saved": {
        "title": "Saved",
        "message": "Preferences saved."
      },
      "set_weight_first": "Please set your weight in My Profile first."
    },
    "error": {
      "save_failed": "Could not save preferences. Try again."
    },
    "info": {
      "goal": {
        "title": "Daily hydration goal",
        "why_title": "Why it matters",
        "why_body": "Staying hydrated supports energy, focus, and overall wellbeing. Your daily goal is a friendly target to help you build a consistent habit — not a medical prescription.",
        "auto_title": "Auto-calculate from weight",
        "auto_prefix": "When enabled, we estimate your goal as ",
        "auto_formula": "body weight (kg) × 35 ml",
        "auto_suffix": ", then round to the nearest 50 ml so it fits the slider nicely. This follows a common guideline many apps use as a starting point.",
        "control_bold": "You're in control: ",
        "control_body": "turn auto-calculate off anytime and nudge the slider until the number feels right for you."
      },
      "presets": {
        "title": "Drink presets",
        "quick_title": "Quick-add buttons",
        "quick_body": "Presets are your three favorite volumes for logging water fast — the same chips you see when you add a drink from the home flow.",
        "tune_prefix": "Tune them to ",
        "tune_bold": "your real cups and bottles",
        "tune_suffix": ". For example, set one preset to 250 ml for your tea mug, or 750 ml for your gym bottle — then logging is one tap instead of typing every time.",
        "tip": "Tip: pick round numbers you actually pour in real life. Small tweaks here make your day-to-day tracking feel effortless."
      },
      "reminders": {
        "title": "Reminders",
        "gentle_title": "Gentle nudges, not nagging",
        "gentle_body": "Reminders help you spread sips across the day so you don't play catch-up at bedtime. Pick an interval that matches your routine, or turn them off whenever you need a quiet day.",
        "quiet_title": "Quiet hours (Do not disturb)",
        "quiet_body": "Set a window when the app should stay silent — for example overnight while you sleep. Outside those hours, reminders can resume on your chosen interval.",
        "quiet_note": "Quiet hours only apply when reminders are turned on. If you pick \"Off\", we won't send interval reminders at all."
      }
    }
  },
  "statistics": {
    "title": "Statistics",
    "error": {
      "load_failed": "Could not load statistics. Pull to try again."
    },
    "weekly_activity": {
      "title": "Weekly Activity"
    },
    "chart": {
      "goal_label": "GOAL",
      "goal_reached": "Goal reached! 🎉",
      "ml_left": "{remain} ml left"
    },
    "footer": {
      "no_goal": "Set a daily goal in preferences to see your progress against each day.",
      "default": "Each bar is one day — tap for details. Keep your rhythm going."
    },
    "breakdown": {
      "title": "Intake Breakdown",
      "caption": "Last 7 days · effective hydration",
      "empty": "Log drinks to see how your intake splits across types.",
      "scroll_hint": "Scroll for more"
    },
    "period": {
      "last_7_days": "Last 7 days"
    },
    "insights": {
      "title": "Weekly Insights",
      "best_day": "Best day",
      "best_day_subtitle": "Most hydration logged",
      "streak": "Current streak",
      "streak_zero": "0 days",
      "streak_days_one": "1 day 🔥",
      "streak_days_other": "{count} days 🔥",
      "no_goal": "Set a daily goal to track streaks",
      "start_streak": "Hit your goal to start",
      "goal_met_today": "Goal met, counting today"
    }
  },
  "history": {
    "title": "History",
    "button": {
      "go_back": "Go back"
    },
    "day": {
      "today": "Today",
      "yesterday": "Yesterday"
    },
    "error": {
      "load_failed": "Could not load your drink history."
    },
    "empty": {
      "title": "No drinks logged yet",
      "body": "Start sipping — every glass counts.\nYour hydration story will appear here."
    }
  },
  "app_update": {
    "title": "App update required",
    "message": "Please update the app to the latest version",
    "button": {
      "android": "Instant update",
      "ios": "Update app"
    }
  },
  "debug": {
    "title": "Debug",
    "section": {
      "device_id": "DEVICE ID",
      "subscriptions": "SUBSCRIPTIONS",
      "reminders": "REMINDERS STATUS"
    },
    "locale": {
      "en": "EN",
      "uk": "UK",
      "sys": "SYS"
    },
    "fcm": {
      "title": "FCM Token",
      "no_token": "No token generated",
      "copied": {
        "title": "Copied",
        "message": "FCM Token copied to clipboard"
      }
    },
    "topic": {
      "title": "Topic: reminder",
      "subscribed": "Subscribed",
      "not_subscribed": "Not subscribed"
    },
    "reminders": {
      "next": "Next Reminder",
      "none": "None",
      "updating": "Updating…",
      "countdown": "in {minutes}m {seconds}s",
      "reset": "Reset & reschedule",
      "test_button": "Test push now (instant)",
      "refreshed": "Schedule refreshed from now.",
      "test_title": "Test push",
      "test_sent": "Sent.",
      "test_failed": "Test push failed: {error}"
    }
  },
  "notifications": {
    "dialog": {
      "title": "Turn on notifications",
      "body": "Hydration reminders need notification permission. You can enable it in system settings.",
      "not_now": "Not now",
      "open_settings": "Open Settings"
    }
  },
  "main_nav": {
    "coming_soon": {
      "add_drink": "Add drink"
    }
  },
  "deep_link": {
    "shared": {
      "title": "Shared hydration",
      "drank_today": "drank today",
      "message": "A friend shared their daily hydration progress with you.",
      "primary_action": "Start tracking yours",
      "secondary_action": "Maybe later"
    },
    "share": {
      "progress_message": "I've drunk {ml} ml today with Daily Water Tracker. Track yours too:\n{url}"
    }
  },
  "language": {
    "english": "English",
    "ukrainian": "Ukrainian"
  },
  "reminder": {
    "msg_01": {
      "title": "Your body is a temple! 🏛️",
      "body": "And it needs a little water right now. Take a sip! 💧"
    },
    "msg_02": {
      "title": "Focus boost! ⚡",
      "body": "Feeling tired? Dehydration might be the reason. Drink some water! 🥤"
    },
    "msg_03": {
      "title": "Water break! ⏲️",
      "body": "Time to step away from the screen and hydrate 🌊"
    },
    "msg_04": {
      "title": "Tiny sip, big win ⭐",
      "body": "Even a small glass counts. Your future self will thank you 🥛"
    },
    "msg_05": {
      "title": "Hydration checkpoint 📍",
      "body": "Quick check: when did you last drink water? Now is a great moment ✅"
    },
    "msg_06": {
      "title": "Glow-up fuel ✨",
      "body": "Water helps your skin and energy. Pour yourself a glass! 🔋"
    },
    "msg_07": {
      "title": "Desk-to-kitchen stroll 🚶‍♂️",
      "body": "Stretch your legs and refill your bottle — two birds, one sip 🚰"
    },
    "msg_08": {
      "title": "Brain fog patrol 🧠",
      "body": "A splash of water can sharpen your thinking. Try it! 💡"
    },
    "msg_09": {
      "title": "Cheers to you! 🥂",
      "body": "You are building a healthy habit. Here is your friendly nudge to sip 😊"
    },
    "msg_10": {
      "title": "Plant mode: watered 🌿",
      "body": "You water your plants — you deserve the same care. Hydrate! 🚿"
    },
    "msg_11": {
      "title": "Power hour sip 💪",
      "body": "Keep momentum going with a refreshing drink of water ⛲"
    },
    "msg_12": {
      "title": "Kind reminder 💙",
      "body": "No pressure — just a gentle invite to drink water if you have not in a while 🌊"
    }
  },
  "legal": {
    "privacy_policy": {
      "title": "Privacy policy",
      "last_updated_label": "Last updated:",
      "last_updated_date": "June 6, 2026",
      "intro": "This Privacy Policy describes how we collect, use, and protect your information when you use Daily Water Tracker and related services.\n\nWe use your data to provide hydration tracking, sync your progress across devices, send optional reminders, and improve app reliability — not for unrelated advertising.",
      "section_collect": "What we collect",
      "collect_account": "Account details you provide (such as email, display name, and profile photo) when you sign in or edit your profile.",
      "collect_hydration": "Hydration data you log (drink type, volume, date, and time) and derived statistics such as weekly activity.",
      "collect_preferences": "App preferences you set, including daily goal, drink presets, theme, and reminder schedule.",
      "collect_notifications": "Device notification permission status, used only if you enable reminders.",
      "collect_diagnostics": "Diagnostic and usage data (for example crash reports and anonymous analytics) to maintain security and fix issues.",
      "section_use": "How we use it",
      "use_sync": "To store, display, and sync your hydration history and profile across your signed-in devices.",
      "use_reminders": "To deliver optional hydration reminders you configure in the app.",
      "use_insights": "To calculate progress, statistics, achievements, and in-app insights.",
      "use_improve": "To operate the service, prevent abuse, and improve performance and stability.",
      "section_sharing": "Sharing & service providers",
      "sharing_processors": "We use trusted infrastructure providers (such as Google Firebase for authentication, cloud storage, and analytics) that process data on our behalf under their own terms and security standards.",
      "sharing_no_sell": "We do not sell your personal information to third parties.",
      "section_rights": "Your rights",
      "rights_delete": "You can delete your account and associated data from the app at any time (see Account → More).",
      "rights_contact": "You may contact us to ask about your data or request correction where applicable.",
      "section_contact": "Contact",
      "contact_body": "If you have questions about this policy, email us at:",
      "contact_email": "mykola.shchypailo@gmail.com"
    }
  },
  "achievements": {
    "loading": "Loading achievements…",
    "error_load_failed": "Could not load achievements. Please try again.",
    "banner_current_rank": "Your rank: {rank}",
    "banner_achieved_rank_label": "Achieved rank",
    "banner_no_rank": "Your rank: Beginner (not yet unlocked)",
    "banner_no_rank_title": "Not unlocked yet",
    "status_locked": "Locked",
    "status_locked_hint": "Reach the previous rank and complete the conditions",
    "status_unlocked": "Rank achieved!",
    "ranks": {
      "beginner": {
        "title": "Beginner",
        "desc": "Log your first glass of water."
      },
      "fan": {
        "title": "Hydration Fan",
        "desc": "Meet your daily goal on 7 separate days."
      },
      "master": {
        "title": "Aqua Master",
        "desc": "30 goal days and 50 liters of hydration."
      },
      "ocean_lord": {
        "title": "Ocean Lord",
        "desc": "100 goal days and 200 liters of hydration."
      },
      "poseidon": {
        "title": "Hydration Deity",
        "desc": "365 goal days and 700 liters of hydration."
      }
    },
    "conditions": {
      "first_log": "First water log",
      "goal_days": "Days with goal met",
      "total_volume": "Total hydration volume"
    },
    "celebration": {
      "barrier_label": "Rank celebration",
      "congrats": "CONGRATULATIONS!",
      "new_status": "Your new status:",
      "primary_action": "Awesome!",
      "share": "Share",
      "share_message": "I just reached {rank} in Daily Water Tracker! I've drunk {ml} ml today.\n{url}",
      "title": "New rank unlocked!",
      "continue": "Continue",
      "teaser_next_rank_title": "Nice!",
      "teaser_next_rank_message": "Next goal: {rank}. Keep it up!",
      "teaser_max_rank_title": "Hydration legend!",
      "teaser_max_rank_message": "You've reached the absolute peak. Keep shining!"
    }
  }
};
static const Map<String, Map<String,dynamic>> mapLocales = {"uk_UA": _uk_UA, "en_US": _en_US};
}
