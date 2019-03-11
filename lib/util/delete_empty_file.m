function delete_empty_file (filepath)
    s = dir(filepath);
    if (s.bytes > 0),  return;  end
    delete(filepath)
end
