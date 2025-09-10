/// Карта пород древесины и средней плотности (кг/м³)
/// Примерные значения, можно расширять и корректировать.
final Map<String, double> speciesDensity = {
  'Pine': 520,        // Сосна
  'Spruce': 450,      // Ель
  'Fir': 440,         // Пихта
  'Larch': 650,       // Лиственница
  'Cedar': 380,       // Кедр
  'Oak': 700,         // Дуб
  'Beech': 720,       // Бук
  'Maple': 600,       // Клён
  'Ash': 690,         // Ясень
  'Birch': 650,       // Берёза
  'Aspen': 450,       // Осина
  'Red Oak': 700,     // Красный дуб
  'White Oak': 700,   // Белый дуб
  'Teak': 650,        // Тик
  'Mahogany': 850,    // Махагон
  'Wenge': 800,       // Венге
  'Iroko': 700,       // Ироко
  'Sapele': 700,      // Сапеле
  'Okoume': 500,      // Окуме
  'Bubinga': 800,     // Бубинга
  'Rosewood': 900,    // Палисандр
  'Meranti': 600,     // Меранти
  'Balau': 700,       // Балау
  'Shorea': 700,      // Шорея
  'Black Walnut': 650,// Чёрный орех
  'Sugar Maple': 600, // Сахарный клён
  'Hickory': 700,     // Гикори
  'Poplar': 400,      // Тополь
  'Alder': 500,       // Ольха
  'American Cherry': 600, // Американская вишня
  'Apple': 600,       // Яблоня
  'Hornbeam': 700,    // Граб
  'Chestnut': 700,    // Каштан
  'Padauk': 700,      // Падук
  'Bamboo': 400,      // Бамбук
  'Douglas Fir': 500, // Дугласова ель
  'Hemlock': 450,     // Пихта
  'Cottonwood': 400,  // Тополь
  'Basswood': 400,    // Липа
  'Butternut': 600,   // Грецкий орех
  'Black Cherry': 600,// Чёрная вишня
  'Black Locust': 700,// Чёрный акация
  'Yellow Birch': 700,// Железняк
  'Sweetgum': 600,    // Сладкий гевея
  'Sycamore': 600,    // Платан
  'Elm': 600,         // Ульм
  'Cypress': 500,     // Кипарис
  'Redwood': 450,     // Секвойя
  'Western Red Cedar': 400, // Западный красный кедр
  'Eastern White Pine': 500, // Восточная белая сосна
  'Southern Yellow Pine': 600, // Южная жёлтая сосна
  'Northern White Cedar': 400, // Северный белый кедр
  'Western Hemlock': 450, // Западная пихта
  'Eastern Hemlock': 450, // Восточная пихта
  'Black Spruce': 450, // Чёрная ель
  'White Spruce': 450, // Белая ель
  'Norway Spruce': 450, // Норвежская ель
  'Sitka Spruce': 450, // Ситка ель
  'Scots Pine': 500,  // Шотландская сосна
  'Eastern Red Cedar': 400, // Восточный красный кедр
  'Western Larch': 650, // Западная лиственница
  'Eastern Larch': 650, // Восточная лиственница
  'Western White Pine': 500, // Западная белая сосна
  'Eastern White Spruce': 450, // Восточная белая ель
  'White Ash': 690,   // Белый ясень
  'Green Ash': 690,   // Зелёный ясень
  'Red Maple': 600,   // Красный клён
  'Silver Maple': 600, // Серебристый клён
  'Boxelder': 600,    // Кленовый клен
  'Black Maple': 600, // Чёрный клён
  'Sugar Pine': 500,  // Сахарная сосна
  'Northern Red Oak': 700, // Северный красный дуб
  'Southern Red Oak': 700, // Южный красный дуб
  'Northern White Oak': 700, // Северный белый дуб
  'Southern White Oak': 700, // Южный белый дуб
  'Northern Black Walnut': 650, // Северный чёрный орех
  'Southern Black Walnut': 650, // Южный чёрный орех
  'Northern Red Maple': 600, // Северный красный клён
  'Southern Red Maple': 600, // Южный красный клён
  'Northern Silver Maple': 600, // Северный серебристый клён
  'Southern Silver Maple': 600, // Южный серебристый клён
  'Northern Boxelder': 600, // Северный кленовый клен
  'Southern Boxelder': 600, // Южный кленовый клен
  'Northern Black Maple': 600, // Северный чёрный клён
  'Southern Black Maple': 600, // Южный чёрный клён
  'Northern Sugar Maple': 600, // Северный сахарный клён
  'Southern Sugar Maple': 600, // Южный сахарный клён
  'Northern White Ash': 690, // Северный белый ясень
  'Southern White Ash': 690, // Южный белый ясень
  'Northern Green Ash': 690, // Северный зелёный ясень  
  'Southern Green Ash': 690, // Южный зелёный ясень
  'Northern Yellow Birch': 700, // Северный железняк
  'Southern Yellow Birch': 700, // Южный железняк
  'Northern Sweetgum': 600, // Северный сладкий гевея
  'Southern Sweetgum': 600, // Южный сладкий гевея
  'Northern Sycamore': 600, // Северный платан
  'Southern Sycamore': 600, // Южный платан
  'Northern Elm': 600, // Северный ульм
  'Southern Elm': 600, // Южный ульм
  'Northern Cypress': 500, // Северный кипарис
  'Southern Cypress': 500, // Южный кипарис
  'Northern Hemlock': 450, // Северная пихта
  'Southern Hemlock': 450, // Южная пихта
  'Northern Redwood': 450, // Северная секвойя
  'Southern Redwood': 450, // Южная секвойя
  'Northern Western Red Cedar': 400, // Северный западный красный кедр
  'Southern Western Red Cedar': 400, // Южный западный красный кедр
  'Northern Eastern White Pine': 500, // Северная восточная белая сосна
  'Southern Eastern White Pine': 500, // Южная восточная белая сосна
  'Northern Southern Yellow Pine': 600, // Северная южная жёлтая сосна
  'Southern Southern Yellow Pine': 600, // Южная южная жёлтая сосна
  'Northern Northern White Cedar': 400, // Северный северный белый кедр
  'Southern Northern White Cedar': 400, // Южный северный белый кедр
  'Northern Western Hemlock': 450, // Северная западная пихта
  'Southern Western Hemlock': 450, // Южная западная пихта
  'Northern Eastern Hemlock': 450, // Северная восточная пихта
  'Southern Eastern Hemlock': 450, // Южная восточная пихта
  'Northern Black Spruce': 450, // Северная чёрная ель
  'Southern Black Spruce': 450, // Южная чёрная ель
  'Northern White Spruce': 450, // Северная белая ель
  'Southern White Spruce': 450, // Южная белая ель
  'Northern Norway Spruce': 450, // Северная норвежская ель
  'Southern Norway Spruce': 450, // Южная норвежская ель
  'Northern Sitka Spruce': 450, // Северная ситка ель
  'Southern Sitka Spruce': 450, // Южная ситка ель
  'Northern Scots Pine': 500, // Северная шотландская сосна
  'Southern Scots Pine': 500, // Южная шотландская сосна
  'Northern Eastern Red Cedar': 400, // Северный восточный красный кедр
  'Southern Eastern Red Cedar': 400, // Южный восточный красный кедр
  'Northern Western Larch': 650, // Северная западная лиственница
  'Southern Western Larch': 650, // Южная западная лиственница
  'Northern Eastern Larch': 650, // Северная восточная лиственница
  'Southern Eastern Larch': 650, // Южная восточная лиственница
  'Northern Western White Pine': 500, // Северная западная белая сосна
  'Southern Western White Pine': 500, // Южная западная белая сосна
  'Northern Eastern White Spruce': 450, // Северная восточная белая ель
  'Southern Eastern White Spruce': 450, // Южная восточная белая ель
};

