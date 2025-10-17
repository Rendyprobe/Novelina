CREATE TABLE IF NOT EXISTS users (
  id bigserial PRIMARY KEY,
  name text NOT NULL,
  email text NOT NULL UNIQUE,
  password_hash text NOT NULL,
  role text NOT NULL DEFAULT 'user',
  created_at timestamptz DEFAULT now()
);

CREATE TABLE IF NOT EXISTS novels (
  id text PRIMARY KEY,
  title text NOT NULL,
  author text NOT NULL,
  synopsis text NOT NULL,
  genre text NOT NULL,
  cover_asset text NOT NULL,
  marketing_message text,
  feature_tag text,
  rating numeric(3,2) DEFAULT 0,
  chapters integer DEFAULT 0,
  created_at timestamptz DEFAULT now()
);

CREATE TABLE IF NOT EXISTS novel_chapters (
  id bigserial PRIMARY KEY,
  novel_id text NOT NULL REFERENCES novels(id) ON DELETE CASCADE,
  chapter_no integer NOT NULL,
  title text NOT NULL,
  content text NOT NULL,
  created_at timestamptz DEFAULT now(),
  UNIQUE (novel_id, chapter_no)
);

CREATE TABLE IF NOT EXISTS novel_stats (
  novel_id text PRIMARY KEY REFERENCES novels(id) ON DELETE CASCADE,
  read_count bigint NOT NULL DEFAULT 0,
  comment_count bigint NOT NULL DEFAULT 0,
  updated_at timestamptz DEFAULT now()
);

CREATE TABLE IF NOT EXISTS novel_comments (
  id bigserial PRIMARY KEY,
  novel_id text NOT NULL REFERENCES novels(id) ON DELETE CASCADE,
  user_name text NOT NULL DEFAULT 'Anonim',
  content text NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_novel_comments_novel_id
  ON novel_comments (novel_id, created_at DESC);

CREATE TABLE IF NOT EXISTS user_bookmarks (
  user_id bigint NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  novel_id text NOT NULL REFERENCES novels(id) ON DELETE CASCADE,
  created_at timestamptz DEFAULT now(),
  PRIMARY KEY (user_id, novel_id)
);

-- Sample data (opsional, hapus jika tidak perlu)
INSERT INTO novels (id, title, author, synopsis, genre, cover_asset, marketing_message, feature_tag, rating, chapters)
VALUES
  ('novel-1', 'Laskar Pelangi', 'Andrea Hirata', 'Kisah persahabatan dan mimpi anak-anak Belitung.', 'Drama Inspiratif', 'assets/images/Laskar_pelangi_sampul.jpg', 'Persahabatan yang menghangatkan hati', 'Bestseller Sepanjang Masa', 4.8, 18),
  ('novel-2', 'Ayat-Ayat Cinta', 'Habiburrahman El Shirazy', 'Drama romansa yang berlatar di Mesir.', 'Romansa Religi', 'assets/images/Ayatayatcinta.jpg', NULL, NULL, 4.7, 24)
ON CONFLICT (id) DO NOTHING;

INSERT INTO novel_chapters (novel_id, chapter_no, title, content)
VALUES
  ('novel-1', 1, 'Sepuluh Anak Kampung', 'Konten bab 1 ...'),
  ('novel-1', 2, 'Mimpi-Mimpi Kecil', 'Konten bab 2 ...'),
  ('novel-2', 1, 'Pertemuan di Metro', 'Konten bab 1 ...')
ON CONFLICT (novel_id, chapter_no) DO NOTHING;

