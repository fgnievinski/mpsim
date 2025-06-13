function visible = logical2onoff (visible)
  if ischar(visible)
    assert(any(strcmp(visible, {'on','off'})));
    return
  end
  visible = logical2char (visible, 'on', 'off');
end
