default_height = (aws_image_upload_id) ->
  $("##{aws_image_upload_id}.aws_image_upload .placeholder img").css('height')

default_width = (aws_image_upload_id) ->
  $("##{aws_image_upload_id}.aws_image_upload .placeholder img").css('width')

load_image = (file, aws_image_upload_id) ->
  loadImage file, (img) ->
    $(img).addClass('thumbnail img-responsive')
    $(img).css('height', default_height(aws_image_upload_id))
    $(img).css('width', default_width(aws_image_upload_id))
    $("##{aws_image_upload_id}.aws_image_upload .images ##{file.id}.image").children('.preview').html(img)
    $("##{aws_image_upload_id}.aws_image_upload .images ##{file.id}.image").removeClass('hidden')

upload_add = (elem, data) ->
  aws_image_upload_id = $(elem).parent().parent().prop('id')
  for file in data.files
    file.id = Math.random().toString(16).substring(3)
    new_image = $("##{aws_image_upload_id}.aws_image_upload .template .image").clone()
    new_image.prop('id', file.id)
    new_image.addClass('hidden')
    new_image.appendTo($("##{aws_image_upload_id}.aws_image_upload .images"))
    load_image(file, aws_image_upload_id)
  unless $(elem).prop('multiple')
    $("##{aws_image_upload_id}.aws_image_upload .placeholder").addClass('invisible')
  $(elem).val('')
  data.process( ->
    elem.fileupload('process', data)
  ).done( ->
    data.submit()
  )

upload_processfail = (e, data) ->
  file = data.files[0]
  aws_image_upload_id = $(e.target).parent().parent().prop('id')
  $("##{aws_image_upload_id}.aws_image_upload .images ##{file.id}.image .preview").addClass('transparent')
  $("##{aws_image_upload_id}.aws_image_upload .images ##{file.id}.image .delete").removeClass('hidden')
  $("##{aws_image_upload_id}.aws_image_upload .images ##{file.id}.image .error.file-too-large").removeClass('hidden')
  $("##{aws_image_upload_id}.aws_image_upload .images ##{file.id}.image .error.file-too-large").css('width', default_width(aws_image_upload_id))

upload_send = (e, data) ->
  file = data.files[0]
  aws_image_upload_id = $(e.target).parent().parent().prop('id')
  $("##{aws_image_upload_id}.aws_image_upload .images ##{file.id}.image .preview").addClass('transparent')
  $("##{aws_image_upload_id}.aws_image_upload .images ##{file.id}.image .delete").addClass('hidden')
  $("##{aws_image_upload_id}.aws_image_upload .images ##{file.id}.image .progress").removeClass('hidden')
  $("##{aws_image_upload_id}.aws_image_upload .images ##{file.id}.image .progress").css('width', parseInt(default_width(aws_image_upload_id)) - 8 + 'px')

upload_progress = (e, data) ->
  progress = parseInt(data.loaded / data.total * 100, 10)
  file = data.files[0]
  aws_image_upload_id = $(e.target).parent().parent().prop('id')
  $("##{aws_image_upload_id}.aws_image_upload .images ##{file.id}.image .progress .progress-bar").css('width', progress + '%')

upload_done = (e, data) ->
  file = data.files[0]
  aws_image_upload_id = $(e.target).parent().parent().prop('id')
  $("##{aws_image_upload_id}.aws_image_upload .images ##{file.id}.image .preview").removeClass('transparent')
  $("##{aws_image_upload_id}.aws_image_upload .images ##{file.id}.image .delete").removeClass('hidden')
  $("##{aws_image_upload_id}.aws_image_upload .images ##{file.id}.image .progress .progress-bar").removeClass('progress-bar-info')
  if $("##{aws_image_upload_id}.aws_image_upload .inputs .file").prop('multiple')
    new_input_hidden = $("##{aws_image_upload_id}.aws_image_upload .inputs input[type=hidden]").first().clone()
    new_input_hidden.prop('id', file.id)
    new_input_hidden.prop('value', $(data.jqXHR.responseXML).find("Location").text())
    new_input_hidden.appendTo($("##{aws_image_upload_id}.aws_image_upload .inputs"))
  else
    $("##{aws_image_upload_id}.aws_image_upload .inputs input[type=hidden]").val($(data.jqXHR.responseXML).find("Location").text())

upload_fail = (e, data) ->
  file = data.files[0]
  aws_image_upload_id = $(e.target).parent().parent().prop('id')
  $("##{aws_image_upload_id}.aws_image_upload .images ##{file.id}.image .preview").addClass('transparent')
  $("##{aws_image_upload_id}.aws_image_upload .images ##{file.id}.image .delete").removeClass('hidden')
  $("##{aws_image_upload_id}.aws_image_upload .images ##{file.id}.image .progress").addClass('hidden')
  $("##{aws_image_upload_id}.aws_image_upload .images ##{file.id}.image .error.upload-failed").removeClass('hidden')
  $("##{aws_image_upload_id}.aws_image_upload .images ##{file.id}.image .error.upload-failed").css('width', default_width(aws_image_upload_id))

$(document).on('turbolinks:load', ->

  $('.aws_image_upload .inputs .file').fileupload({
    paramName: 'file',
    dataType: 'XML',
    replaceFileInput: false,
    maxFileSize: 1024 * 500,
    add: (e, data) ->
      upload_add($(this), data)
    processfail: (e, data) ->
      upload_processfail(e, data)
    send: (e, data) ->
      upload_send(e, data)
    progress: (e, data) ->
      upload_progress(e, data)
    done: (e, data) ->
      upload_done(e, data)
    fail: (e, data) ->
      upload_fail(e, data)
  })

  $('.aws_image_upload .placeholder img').click (e) ->
    aws_image_upload_id = $(this).parent().parent().prop('id')
    $("##{aws_image_upload_id}.aws_image_upload .inputs .file").click()

  $('.aws_image_upload .placeholder img').on('load', ->
    aws_image_upload_id = $(this).parent().parent().prop('id')
    $("##{aws_image_upload_id}.aws_image_upload .images .image .preview img").each ->
      $(this).css('height', default_height(aws_image_upload_id))
      $(this).css('width', default_width(aws_image_upload_id))
  )

  $('.aws_image_upload').on('click', '.images .image .delete', ->
    aws_image_upload_id = $(this).parent().parent().parent().prop('id')
    if $("##{aws_image_upload_id}.aws_image_upload .inputs .file").prop('multiple')
      file_id = $(this).parent().prop('id')
      $("##{aws_image_upload_id}.aws_image_upload .inputs ##{file_id}").remove()
    else
      $("##{aws_image_upload_id}.aws_image_upload .placeholder").removeClass('invisible')
      $("##{aws_image_upload_id}.aws_image_upload .inputs input[type=hidden]").val('')
    $(this).parent().remove()
  )
)