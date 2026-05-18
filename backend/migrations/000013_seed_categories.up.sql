DO $$
DECLARE
  v_meyve UUID;
  v_sebze UUID;
  v_baklagil UUID;
  v_sut UUID;
  v_bal UUID;
  v_yumurta UUID;
  v_zeytin UUID;
  v_kuruyemis UUID;
  v_dogal UUID;
BEGIN

INSERT INTO categories (name, slug, sort_order) VALUES ('Meyve', 'meyve', 1) RETURNING id INTO v_meyve;
INSERT INTO categories (name, slug, sort_order) VALUES ('Sebze', 'sebze', 2) RETURNING id INTO v_sebze;
INSERT INTO categories (name, slug, sort_order) VALUES ('Baklagil ve Tahıl', 'baklagil-tahil', 3) RETURNING id INTO v_baklagil;
INSERT INTO categories (name, slug, sort_order) VALUES ('Süt Ürünleri', 'sut-urunleri', 4) RETURNING id INTO v_sut;
INSERT INTO categories (name, slug, sort_order) VALUES ('Bal ve Arı Ürünleri', 'bal-ari-urunleri', 5) RETURNING id INTO v_bal;
INSERT INTO categories (name, slug, sort_order) VALUES ('Yumurta', 'yumurta', 6) RETURNING id INTO v_yumurta;
INSERT INTO categories (name, slug, sort_order) VALUES ('Zeytin ve Zeytinyağı', 'zeytin-zeytinyagi', 7) RETURNING id INTO v_zeytin;
INSERT INTO categories (name, slug, sort_order) VALUES ('Kuruyemiş', 'kuruyemis', 8) RETURNING id INTO v_kuruyemis;
INSERT INTO categories (name, slug, sort_order) VALUES ('Doğal Ürünler', 'dogal-urunler', 9) RETURNING id INTO v_dogal;

INSERT INTO categories (name, slug, parent_id, sort_order) VALUES
  ('Çilek', 'cilek', v_meyve, 1),
  ('Elma', 'elma', v_meyve, 2),
  ('Armut', 'armut', v_meyve, 3),
  ('Kiraz', 'kiraz', v_meyve, 4),
  ('Üzüm', 'uzum', v_meyve, 5),
  ('Şeftali', 'seftali', v_meyve, 6),
  ('Kayısı', 'kayisi', v_meyve, 7),
  ('İncir', 'incir', v_meyve, 8),
  ('Nar', 'nar', v_meyve, 9),
  ('Karpuz', 'karpuz', v_meyve, 10),
  ('Kavun', 'kavun', v_meyve, 11);

INSERT INTO categories (name, slug, parent_id, sort_order) VALUES
  ('Domates', 'domates', v_sebze, 1),
  ('Salatalık', 'salatalik', v_sebze, 2),
  ('Biber', 'biber', v_sebze, 3),
  ('Patlıcan', 'patlican', v_sebze, 4),
  ('Kabak', 'kabak', v_sebze, 5),
  ('Patates', 'patates', v_sebze, 6),
  ('Soğan', 'sogan', v_sebze, 7),
  ('Sarımsak', 'sarimsak', v_sebze, 8),
  ('Havuç', 'havuc', v_sebze, 9),
  ('Marul', 'marul', v_sebze, 10),
  ('Lahana', 'lahana', v_sebze, 11),
  ('Brokoli', 'brokoli', v_sebze, 12);

INSERT INTO categories (name, slug, parent_id, sort_order) VALUES
  ('Nohut', 'nohut', v_baklagil, 1),
  ('Mercimek', 'mercimek', v_baklagil, 2),
  ('Fasulye', 'fasulye', v_baklagil, 3),
  ('Bulgur', 'bulgur', v_baklagil, 4),
  ('Buğday', 'bugday', v_baklagil, 5),
  ('Mısır', 'misir', v_baklagil, 6),
  ('Pirinç', 'pirinc', v_baklagil, 7);

INSERT INTO categories (name, slug, parent_id, sort_order) VALUES
  ('Süt', 'sut', v_sut, 1),
  ('Peynir', 'peynir', v_sut, 2),
  ('Yoğurt', 'yogurt', v_sut, 3),
  ('Tereyağı', 'tereyagi', v_sut, 4),
  ('Kaymak', 'kaymak', v_sut, 5);

INSERT INTO categories (name, slug, parent_id, sort_order) VALUES
  ('Bal', 'bal', v_bal, 1),
  ('Polen', 'polen', v_bal, 2),
  ('Propolis', 'propolis', v_bal, 3),
  ('Arı Sütü', 'ari-sutu', v_bal, 4);

INSERT INTO categories (name, slug, parent_id, sort_order) VALUES
  ('Köy Yumurtası', 'koy-yumurtasi', v_yumurta, 1),
  ('Organik Yumurta', 'organik-yumurta', v_yumurta, 2);

INSERT INTO categories (name, slug, parent_id, sort_order) VALUES
  ('Zeytin', 'zeytin', v_zeytin, 1),
  ('Zeytinyağı', 'zeytinyagi', v_zeytin, 2),
  ('Zeytin Ezmesi', 'zeytin-ezmesi', v_zeytin, 3);

INSERT INTO categories (name, slug, parent_id, sort_order) VALUES
  ('Ceviz', 'ceviz', v_kuruyemis, 1),
  ('Fındık', 'findik', v_kuruyemis, 2),
  ('Badem', 'badem', v_kuruyemis, 3),
  ('Antep Fıstığı', 'antep-fistigi', v_kuruyemis, 4);

INSERT INTO categories (name, slug, parent_id, sort_order) VALUES
  ('Reçel', 'recel', v_dogal, 1),
  ('Pekmez', 'pekmez', v_dogal, 2),
  ('Tarhana', 'tarhana', v_dogal, 3),
  ('Erişte', 'eriste', v_dogal, 4),
  ('Salça', 'salca', v_dogal, 5),
  ('Turşu', 'tursu', v_dogal, 6);

END $$;
