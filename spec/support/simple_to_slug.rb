class SimpleToSlug
  def to_slug(record)
    "to_slug_#{record.id}"
  end

  def to_slug_was(record)
    "to_slug_was_#{record.id}"
  end

  def to_slug_will(record)
    "to_slug_will_#{record.id}"
  end
end