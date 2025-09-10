/// Карта пород древесины и процента увеличения объёма с корой.
/// Значение — это процент (например, 0.07 = 7%).
/// Комментарий — перевод на русский язык.
final Map<String, double> speciesData = {
  'Pine': 0.07,        // Сосна, 7%
  'Spruce': 0.06,      // Ель, 6%
  'Fir': 0.06,         // Пихта, 6%
  'Larch': 0.08,       // Лиственница, 8%
  'Cedar': 0.05,       // Кедр, 5%
  'Oak': 0.06,         // Дуб, 6%
  'Beech': 0.06,       // Бук, 6%
  'Maple': 0.05,       // Клён, 5%
  'Ash': 0.06,         // Ясень, 6%
  'Birch': 0.07,       // Берёза, 7%
  'Aspen': 0.07,       // Осина, 7%
  'Teak': 0.04,        // Тик, 4%
  'Mahogany': 0.04,    // Махагон, 4%
  'Wenge': 0.05,       // Венге, 5%
  'Iroko': 0.05,       // Ироко, 5%
  'Sapele': 0.04,      // Сапеле, 4%
  'Okoume': 0.06,      // Окуме, 6%
  'Bubinga': 0.04,     // Бубинга, 4%
  'Rosewood': 0.04,    // Палисандр, 4%
  'Meranti': 0.06,     // Меранти, 6%
  'Balau': 0.06,       // Балау, 6%
  'Shorea': 0.06,      // Шорея, 6%
  'Red Oak': 0.06,     // Красный дуб, 6%
  'White Oak': 0.06,   // Белый дуб, 6%
  'Black Walnut': 0.05,// Чёрный орех, 5%
  'Sugar Maple': 0.05, // Сахарный клён, 5%
  'Hickory': 0.05,     // Гикори, 5%
  'Poplar': 0.06,      // Тополь, 6%
  'Alder': 0.06,       // Ольха, 6%
  'American Cherry': 0.05, // Американская вишня, 5%
  'Apple': 0.05,       // Яблоня, 5%
  'Hornbeam': 0.06,    // Граб, 6%
  'Chestnut': 0.06,    // Каштан, 6%
  'Padauk': 0.04,      // Падук, 4%
  'Bamboo': 0.05,      // Бамбук, 5%
  'Douglas Fir': 0.06, // Дугласова ель, 6%
  'Hemlock': 0.06,     // Пихта, 6%
  'Cottonwood': 0.06,  // Тополь, 6%
  'Basswood': 0.06,    // Липа, 6%
  'Butternut': 0.05,   // Грецкий орех, 5%
  'Black Cherry': 0.05,// Чёрная вишня, 5%
  'Black Locust': 0.06,// Чёрный акация, 6%
  'Yellow Birch': 0.06,// Железняк, 6%
  'Sweetgum': 0.05,    // Сладкий гевея, 5%
  'Sycamore': 0.05,    // Платан, 5%
  'Elm': 0.05,         // Ульм, 5%
  'Cypress': 0.06,     // Кипарис, 6%
  'Redwood': 0.06,     // Секвойя, 6%
  'Western Red Cedar': 0.05, // Западный красный кедр, 5%
  'Eastern White Pine': 0.06, // Восточная белая сосна, 6%
  'Southern Yellow Pine': 0.06, // Южная жёлтая сосна, 6%
  'Northern White Cedar': 0.05, // Северный белый кедр, 5%
  'Western Hemlock': 0.06, // Западная пихта, 6%
  'Eastern Hemlock': 0.06, // Восточная пихта, 6%
  'Black Spruce': 0.06, // Чёрная ель, 6%
  'White Spruce': 0.06, // Белая ель, 6%
  'Norway Spruce': 0.06, // Норвежская ель, 6%
  'Sitka Spruce': 0.06, // Ситка ель, 6%
  'Scots Pine': 0.07,  // Шотландская сосна, 7%
  'Eastern Red Cedar': 0.05, // Восточный красный кедр, 5%
  'Western Larch': 0.06, // Западная лиственница, 6%
  'Eastern Larch': 0.06, // Восточная лиственница, 6%
  'Western White Pine': 0.06, // Западная белая сосна, 6%
  'Eastern White Spruce': 0.06, // Восточная белая ель, 6%
  'White Ash': 0.06,   // Белый ясень, 6%
  'Green Ash': 0.06,   // Зелёный ясень, 6%
  'Red Maple': 0.06,   // Красный клён, 6%
  'Silver Maple': 0.06, // Серебристый клён, 6%
  'Boxelder': 0.06,    // Кленовый клен, 6%
  'Black Maple': 0.06, // Чёрный клён, 6%
  'Sugar Pine': 0.06,  // Сахарная сосна, 6%
  'Northern Red Oak': 0.06, // Северный красный дуб, 6%
  'Southern Red Oak': 0.06, // Южный красный дуб, 6%
  'Northern White Oak': 0.06, // Северный белый дуб, 6%
  'Southern White Oak': 0.06, // Южный белый дуб, 6%
  'Northern Black Walnut': 0.06, // Северный чёрный орех, 6%
  'Southern Black Walnut': 0.06, // Южный чёрный орех, 6%
  'Northern Red Maple': 0.06, // Северный красный клён, 6%
  'Southern Red Maple': 0.06, // Южный красный клён, 6%
  'Northern Silver Maple': 0.06, // Северный серебристый клён, 6%
  'Southern Silver Maple': 0.06, // Южный серебристый клён, 6%
  'Northern Boxelder': 0.06, // Северный кленовый клен, 6%
  'Southern Boxelder': 0.06, // Южный кленовый клен, 6%
  'Northern Black Maple': 0.06, // Северный чёрный клён, 6%
  'Southern Black Maple': 0.06, // Южный чёрный клён, 6%
  'Northern Sugar Maple': 0.06, // Северный сахарный клён, 6%
  'Southern Sugar Maple': 0.06, // Южный сахарный клён, 6%
  'Northern White Ash': 0.06, // Северный белый ясень, 6%
  'Southern White Ash': 0.06, // Южный белый ясень, 6%
  'Northern Green Ash': 0.06, // Северный зелёный ясень, 6%
  'Southern Green Ash': 0.06, // Южный зелёный ясень, 6%
  'Northern Yellow Birch': 0.06, // Северный железняк, 6%
  'Southern Yellow Birch': 0.06, // Южный железняк, 6%
  'Northern Sweetgum': 0.06, // Северный сладкий гевея, 6%
  'Southern Sweetgum': 0.06, // Южный сладкий гевея, 6%
  'Northern Sycamore': 0.06, // Северный платан, 6%
  'Southern Sycamore': 0.06, // Южный платан, 6%
  'Northern Elm': 0.06, // Северный ульм, 6%
  'Southern Elm': 0.06, // Южный ульм, 6%
  'Northern Cypress': 0.06, // Северный кипарис, 6%
  'Southern Cypress': 0.06, // Южный кипарис, 6%
  'Northern Redwood': 0.06, // Северная секвойя, 6%
  'Southern Redwood': 0.06, // Южная секвойя, 6%
  'Northern Western Red Cedar': 0.06, // Северный западный красный кедр, 6%
  'Southern Western Red Cedar': 0.06, // Южный западный красный кедр, 6%
  'Northern Eastern White Pine': 0.06, // Северная восточная белая сосна, 6%
  'Southern Eastern White Pine': 0.06, // Южная восточная белая сосна, 6%
  'Northern Southern Yellow Pine': 0.06, // Северная южная жёлтая сосна, 6%
  'Southern Southern Yellow Pine': 0.06, // Южная южная жёлтая сосна, 6%
  'Northern Northern White Cedar': 0.06, // Северный северный белый кедр, 6%
  'Southern Northern White Cedar': 0.06, // Южный северный белый кедр, 6%
  'Northern Western Hemlock': 0.06, // Северная западная пихта, 6%
  'Southern Western Hemlock': 0.06, // Южная западная пихта, 6%
  'Northern Eastern Hemlock': 0.06, // Северная восточная пихта, 6%
  'Southern Eastern Hemlock': 0.06, // Южная восточная пихта, 6%
  'Northern Black Spruce': 0.06, // Северная чёрная ель, 6%
  'Southern Black Spruce': 0.06, // Южная чёрная ель, 6%
  'Northern White Spruce': 0.06, // Северная белая ель, 6%
  'Southern White Spruce': 0.06, // Южная белая ель, 6%
  'Northern Norway Spruce': 0.06, // Северная норвежская ель, 6%
  'Southern Norway Spruce': 0.06, // Южная норвежская ель, 6%
  'Northern Sitka Spruce': 0.06, // Северная ситка ель,
  'Southern Sitka Spruce': 0.06, // Южная ситка ель, 6%
  'Northern Scots Pine': 0.07, // Северная шотландская сосна, 7%
  'Southern Scots Pine': 0.07, // Южная шотландская сосна, 7%
  'Northern Eastern Red Cedar': 0.05, // Северный восточный красный кедр, 5%
  'Southern Eastern Red Cedar': 0.05, // Южный восточный красный кедр, 5%
  'Northern Western Larch': 0.06, // Северная западная лиственница, 6%
  'Southern Western Larch': 0.06, // Южная западная лиственница, 6%
  'Northern Eastern Larch': 0.06, // Северная восточная лиственница, 6%
  'Southern Eastern Larch': 0.06, // Южная восточная лиственница, 6%
  'Northern Western White Pine': 0.06, // Северная западная белая сосна, 6%
  'Southern Western White Pine': 0.06, // Южная западная белая сосна, 6%
  'Northern Eastern White Spruce': 0.06, // Северная восточная белая ель, 6%
  'Southern Eastern White Spruce': 0.06, // Южная восточная белая ель, 6%
  'Northern Hemlock': 0.06, // Северная пихта, 6%
  'Southern Hemlock': 0.06, // Южная пихта, 6%
};