function status = mkdir_error (path)
    [status, message, identifier] = mkdir(path);
    if (status == 1),  return;  end
    message = [message, sprintf('\n'), path];
    error(identifier, message);
end
