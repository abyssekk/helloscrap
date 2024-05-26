$(document).on 'turbolinks:load', ->
  $('[data-provider="summernote"]').each ->
    $(this).summernote
      height: 300
      toolbar: [
        ['style', ['style', 'fontsize', 'fontsizeunit']],
        ['font', ['bold', 'italic', 'underline', 'clear']],
        ['color', ['color', 'forecolor']],
        ['para', ['ul', 'ol', 'paragraph']],
        ['table', ['table']],
        ['insert', ['link']],
        ['view', ['undo', 'redo', 'fullscreen']]
      ]