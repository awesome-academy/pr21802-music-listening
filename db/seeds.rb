User.skip_callback :create, :after, :send_welcome_email
user = User.find_or_initialize_by(
  name: "123123",
  email: "123@123.com"
)
user.password = "123123"
user.skip_confirmation!
user.add_role :admin unless user.has_role? :admin
user.save!
User.set_callback :create, :after, :send_welcome_email

metadata_files = Dir.glob("import/*.flac.json")
metadata_files += Dir.glob("import/*.m4a.json")

metadata_files.each do |metadata_file|
  metadata = JSON.parse(File.read(metadata_file))

  imported_filename = metadata["format"]["filename"]
  imported_duration = metadata["format"]["duration"]
  # imported_bit_rate = metadata["format"]["bit_rate"]
  imported_tags = metadata["format"]["tags"].transform_keys!(&:downcase)
  imported_title = imported_tags["title"]
  imported_album = imported_tags["album"]
  imported_genre = imported_tags["genre"]
  # imported_composer = imported_tags["composer"]
  imported_track_no =
    if imported_tags["track"].blank?
      1
    else
      imported_tags["track"].split("/").first
    end
  imported_year = imported_tags["date"]
  imported_artist = imported_tags["artist"]
  imported_album_artist = imported_tags["album_artist"] || imported_artist
  imported_disc_no =
    if imported_tags["disc"].blank?
      1
    else
      imported_tags["disc"].split("/").first
    end
  album = Album.find_or_create_by name: imported_album,
    disc_no: imported_disc_no
  album.year = imported_year if album.year.blank?
  if album.cover.blank?
    coverpath = imported_filename + ".jpg"
    album.cover = File.open(coverpath) if File.file? coverpath
  end
  album.save!

  artist = Artist.find_or_create_by name: imported_artist
  if artist.cover.blank?
    coverpath = imported_filename + ".jpg"
    artist.cover = File.open(coverpath) if File.file? coverpath
  end
  artist.save!

  album_artist = Artist.find_or_create_by name: imported_album_artist

  AlbumArtist.find_or_create_by album: album, artist: album_artist
  if imported_genre.present?
    category = Category.find_or_create_by name: imported_genre
    category.published = true if category.published.blank?
    category.tag = 0 if category.tag.blank?
    category.save!
  end

  song = Song.find_or_create_by(
    name: imported_title,
    duration: imported_duration,
    artist: artist,
    album: album,
    track_no: imported_track_no,
    year: imported_year
  )

  SongCategory.find_or_create_by(
    song: song,
    category: category
  ) if category.present?

  AlbumCategory.find_or_create_by(
    album: album,
    category: category
  ) if category.present?

  song.file = File.open(imported_filename) if song.file.blank?
  song.save!

end

package = Package.find_or_create_by name: "Premium"
Plan.find_or_create_by package: package, name: "Premium 1 month",
  duration: 30, amount: 5
Plan.find_or_create_by package: package, name: "Premium 6 months",
  duration: 180, amount: 30
Plan.find_or_create_by package: package, name: "Premium 12 year",
  duration: 365, amount: 50
