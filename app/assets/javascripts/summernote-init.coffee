$(document).on 'turbolinks:load', ->
  $('[data-provider="summernote"]').each ->
    $(this).summernote
      height: 300
      toolbar: [
        ['font', ['bold', 'italic', 'underline', 'clear']],
        ['color', ['color', 'forecolor']],
        ['para', ['ul', 'ol', 'paragraph']],
        ['table', ['table']],
        ['view', ['undo', 'redo', 'fullscreen']]
      ]