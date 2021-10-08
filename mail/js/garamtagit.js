// Array indexOf IE8

if (!Array.prototype.indexOf) {

	Array.prototype.indexOf = function(elt /* , from */) {

		var len = this.length >>> 0;



		var from = Number(arguments[1]) || 0;

		from = (from < 0) ? Math.ceil(from) : Math.floor(from);

		if (from < 0)

			from += len;



		for (; from < len; from++) {

			if (from in this && this[from] === elt)

				return from;

		}

		return -1;

	};

}



objRecipients = new Array();



function getRecipients() {

	return objRecipients;

}



function setRecipients(ret) {

	if (ret != null) {

		var delRecipients = objRecipients.slice();

		for ( var i = 0, ilen = ret.length; i < ilen; i++) {

			var retAddress = ret[i];

			var type = parseInt(retAddress.type);

			switch (type) {

			case 0:

				$('#reTo').garamtagit("add", retAddress);

				break;

			case 1:

				$('#reCc').garamtagit("add", retAddress);

				break;

			case 2:

				$('#reBcc').garamtagit("add", retAddress);

				break;

			}

			var index = delRecipients.indexOf(retAddress);

			if (index > -1)

				delRecipients.splice(index, 1);

		}



		for ( var i = 0, len = delRecipients.length; i < len; i++) {

			var delAddress = delRecipients[i];

			var type = parseInt(delAddress.type);

			switch (type) {

			case 0:

				$('#reTo').garamtagit("del", delAddress);

				break;

			case 1:

				$('#reCc').garamtagit("del", delAddress);

				break;

			case 2:

				$('#reBcc').garamtagit("del", delAddress);

				break;

			}

		}

	}

}



(function($) {

	$.widget("ui.garamtagit", {

		options : {

			type : 0

		},

		// initialization function

		_create : function() {

			var self = this;

			var name = self.element.attr('name');

			var tagsId = self.tagsId = name + '_ul';

			var autoId = self.autoId = name + '_input';

			var hideId = self.hideId = name + '_datas';



			var ul = $('<ul></ul>').addClass("autocompleteTag ui-widget").attr("id", tagsId).data("type", this.options.type);

			var li = $('<li></li>').addClass("tag-disabled");

			var input = $('<input type="text">').addClass("searchInput").attr("id", autoId).css({

				"margin-right" : "5px"

			});

			var datas = $('<input type="hidden" name="' + hideId + '" id="' + hideId + '">');



			input.autocomplete({

				minLength : Number.MAX_VALUE,

				source : function(request, response) {

					var elem = $(this.element);



					// 쌍따옴표 안에 있는 콤마는 공백으로 변경합니다.

					request.term.replace(/\"[^\"]*\"/g, function(str) {

						request.term = request.term.replace(str, str.replace(/,/g, " "));

					});



					// 홀따옴표는 제거합니다.

					request.term.replace(/\'/g, function(str) {

						request.term = request.term.replace(str, str.replace(/\'/g, ""));

					});



					// 세미콜론(;)은 콤마로 치환합니다.

					request.term.replace(/\;/g, function(str) {

						request.term = request.term.replace(str, str.replace(/\;/g, ","));

					});



					$.ajax({

						url : "/mail/address_mail_json2.jsp",

						dataType : "json",

						data : {

							searchValue : request.term,

							addressbook : 1,

							users : 1,

							department : 1,

							mail_group : 1,

							mail_autocomplete : 0,

							mail_form : 0,

							mail_representation : 1,

							dpid : $('select[name=addressBookList]').val()

						},

						success : function(data) {

							elem.removeClass("ui-autocomplete-loading");

							var terms = request.term.split(",");

							var searchValue = new Array();

							var newDate = new Array();



							for ( var i = 0, len = terms.length; i < len; i++) {

								var search = $.trim(terms[i]);

								if (search == "")

									continue;



								if (data[search] === undefined) {

									self._log(search + ' 검색 실패');

								} else if (data[search].length == 0) {

									self._log(search + ' 검색 결과 0건');

									var objAddress = ParseRecipient(search);



									var strAddressLower = objAddress.address.toLowerCase();

									var em = strAddressLower.match(/^[_\-\.0-9a-zA-Z]{2,}@[-.0-9a-zA-z]{2,}\.[a-zA-Z]{2,4}$/);



									if (!em) {

										if (terms.length == 1) {

											// 콤마없이 단일검색일 경우에는 `alert`창으로 검색결과가 없다고 알림

											input.unbind("blur.autocomplete");

											if (confirm("\"" + search + "\" 는(은) 잘못된 메일주소입니다! (검색결과 없음)\n계속 검색하시겠습니까?")) {

												searchValue.push(search);

												elem.focus();

											}

											input.bind("blur.autocomplete", function(event) {

												eventSearch(this, event);

											});

										} else {

											// 콤마있고 다중검색일 경우에는 리스트에 검색결과가 없다고 출력

											searchValue.push(search);

											newDate = newDate.concat([ {

												"value" : search,

												"search" : true,

												"size" : -1

											} ]);

										}

									} else if (objAddress != null && objAddress.address != "") {

										objAddress.toString = "\"" + ((objAddress.personal == "") ? objAddress.address : objAddress.personal) + "\" <" + objAddress.address + ">";

										objAddress.toDisplay = objAddress.toString;

										self._addTag(objAddress);

									} else {

										if (terms.length == 1) {

											// 콤마없이 단일검색일 경우에는 `alert`창으로 검색결과가 없다고 알림

											input.unbind("blur.autocomplete");

											if (confirm("\"" + search + "\" 에 대한 검색결과가 없습니다.\n계속 검색하시겠습니까?")) {

												searchValue.push(search);

												elem.focus();

											}

											input.bind("blur.autocomplete", function(event) {

												eventSearch(this, event);

											});



										} else {

											// 콤마있고 다중검색일 경우에는 리스트에 검색결과가 없다고 출력

											searchValue.push(search);

											newDate = newDate.concat([ {

												"value" : search,

												"search" : true,

												"size" : 0

											} ]);

										}

									}

								} else if (data[search].length == 1) {

									self._log(search + ' 검색 결과 1건');

									self._addTag(data[search][0]);

								} else if (data[search].length > 1) {

									self._log(search + ' 검색 결과 2건 이상');

									searchValue.push(search);

									newDate = newDate.concat([ {

										"value" : search,

										"search" : true,

										"size" : data[search].length

									} ]);

									newDate = newDate.concat(data[search]);

								}

							}

							elem.val(searchValue.join(", "));

							response(newDate);

						},

						error : function(jqXHR, textStatus, errorThrown) {

							elem.removeClass("ui-autocomplete-loading");

						}

					});

				},

				select : function(event, ui) {

					self._addTag(ui.item);

					$(event.target).val("");

					return false;

				},

				open : function(event, ui) {

					input.unbind("blur.autocomplete");

					var elem = $(event.target);

					if (elem.next().html() == null) {

						$('input[name=autocomplete_check]:checked').prop("checked", false);

						var span = $('<span class=\'button gray medium\'>선택</span>').css({

							"margin-right" : "5px"

						}).bind('click', function() {

							var checkboxs = $('input[name=autocomplete_check]:checked');

							for ( var i = 0, len = checkboxs.length; i < len; i++) {

								self._addTag($(checkboxs[i]).data('item.autocomplete'));

							}

							$(this).remove();

							elem.autocomplete("widget").hide();

							elem.val("");

							input.bind("blur.autocomplete", function(event) {

								eventSearch(this, event);

							});

						});

						elem.after(span);

					}

				},

				close : function(event, ui) {

					input.bind("blur.autocomplete", function(event) {

						eventSearch(this, event);

					});

					var elem = $(event.target);

					var span = elem.next();

					if (span.text() == '선택')

						span.remove();

				}

			});



			input.bind("keydown.autocomplete", function(event) {

				if (event.keyCode == $.ui.keyCode.ENTER) {

					eventSearch(this, event);

				}

			});



			input.bind("blur.autocomplete", function(event) {

				eventSearch(this, event);

			});



			input.data('autocomplete')._renderMenu = function(ul, items) {

				var self = this;

				var search = "";

				$.each(items, function(index, item) {

					if (item.search) {

						search = item.value;

						var text = "";

						if (item.size == -1) {

							text = $('<span></span>').css({

								"display" : "inline-block",

								"padding-left" : "22px"

							}).text("\"" + search + "\" 는(은) 잘못된 메일주소입니다! (검색결과 없음)");

						} else {

							text = $('<span></span>').css({

								"display" : "inline-block",

								"padding-left" : "22px"

							}).text("\"" + search + "\" 검색결과 (" + item.size + "건)");

						}
                        
						var li = $('<li></li>').data("item.autocomplete", {

							value : $(self.element).val()

						}).addClass("ui-autocomplete-category ui-menu-item").css({

							"padding" : ".2em 0",

							"line-height" : "1.5",
                            "background" : "#ccc"

						}).html(text);

						ul.append(li);

					} else {

						self._renderItem(ul, item, search);

					}

				});

			};



			input.data('autocomplete')._renderItem = function(ul, item, search) {

				var re = new RegExp(search, "gi");

				var label = item.label.replace('<', '&lt').replace('>', '&gt');

				label = label.replace(re, '<span class="blue">' + "$&" + "</span>");

				return $("<li></li>").data("item.autocomplete", item).append($("<input type='checkbox' name='autocomplete_check'>").data("item.autocomplete", item)).append($("<a></a>").html(label).css({

					"display" : "inline-block",

					"color" : "#888"

				})).appendTo(ul);

			};



			this.element.hide();

			this.element.wrap(ul);

			this.element.wrap(li);

			this.element.parent().append(datas);

			this.element.parent().append(input);



			$("#" + tagsId).sortable({

				items : "li:not(.tag-disabled)",

				connectWith : ".autocompleteTag",

				update : function(event, ui) {

					self._log('update');

					var type = $(event.target).data("type");

					var item = ui.item.data("item.objAddress");

					item.type = type;

					ui.item.data("item.objAddress", item);

					self.sendformat();

				}

			});

			// $("#"+tagsId).disableSelection();

		},

		del : function(objAddress, event) {

			this._log("del");

			var tags = $("#" + this.tagsId).find('li');

			for ( var i = 0, len = tags.length; i < len; i++) {

				var tag = $(tags[i]);

				if (objAddress.toDisplay == tag.text()) {

					var index = objRecipients.getAddressIndex(objAddress);

					if (index != null)

						objRecipients.remove(index);

					tag.remove();

				}

			}

			this.sendformat();

		},

		adds : function(str) {

			var self = this;

			// 쌍따옴표 안에 있는 콤마는 공백으로 변경합니다.

			str.replace(/\"[^\"]*\"/g, function(str) {

				str = str.replace(str, str.replace(/,/g, " "));

			});



			var terms = str.split(",");

			for ( var i = 0, len = terms.length; i < len; i++) {

				var search = $.trim(terms[i]);

				var objAddress = ParseRecipient(search);

				if (objAddress != null && objAddress.address != "") {

					objAddress.toString = "\"" + ((objAddress.personal == "") ? objAddress.address : objAddress.personal) + "\" <" + objAddress.address + ">";

					objAddress.toDisplay = objAddress.toString;

					self._addTag(objAddress);

				}

			}

		},

		addo : function(arr) {

			for ( var i = 0, len = arr.length; i < len; i++) {

				var obj = arr[i];

				this._addTag(obj);

			}

		},

		add : function(objAddress, event) {

			var self = this;

			self._log("add");

			var tags = $("#" + this.tagsId).find('li');

			for ( var i = 0, len = tags.length; i < len; i++) {

				var tag = $(tags[i]);

				if (objAddress.toDisplay == tag.text())

					return;

			}

			if (objAddress.address && objAddress.address.indexOf("'") > -1) {

				objAddress.address = objAddress.address.replace(/\'/g, "");

				objAddress.toString = "\"" + ((objAddress.personal == "") ? objAddress.address : objAddress.personal) + "\" <" + objAddress.address + ">";

				objAddress.toDisplay = objAddress.toString;

			}



			objRecipients.push(objAddress);



			var tagName = $('<span></span>');

			tagName.addClass("ui-button-text");

			tagName.css({

				"padding" : ".2em 2.3em .2em .5em"

			});

			tagName.text(objAddress.toDisplay);

			var tagClose = $('<span></span>');

			tagClose.addClass("ui-button-icon-secondary ui-icon ui-icon-close").css({

				"background-color" : "inherit",

				"background-position" : "-80px -128px"

			});

			tagClose.bind("click", function(e) {

				var li = $(this).parent();

				var objAddress = li.data("item.objAddress");

				var index = objRecipients.getAddressIndex(objAddress);

				if (index != null)

					objRecipients.remove(index);

				$(this).parent().remove();

				self.sendformat();

			});

			var tag = $('<li></li>').addClass("ui-button ui-widget ui-state-default ui-corner-all ui-button-text-icon-secondary");

			tag.data("item.objAddress", objAddress);

			tag.append(tagName);

			tag.append(tagClose);

			$("#" + this.tagsId).append(tag);

			this.sendformat();

		},

		sendformat : function() {

			var tags = $("#" + this.tagsId).find('li');

			var data = new Array();

			var datas = new Array();

			for ( var i = 0, len = tags.length; i < len; i++) {

				var tag = $(tags[i]);

				if (tag.hasClass("ui-button")) {

					var item = tag.data("item.objAddress");

					// console.log(JSON.stringify(item));

					// data.push(item.toString);

					data.push(AddressToString(item));

					// try {

					// console.log("item.toString: " + item.toString);

					// console.log("item[\"toString\"]: " + item["toString"]);

					// } catch (e) {

					// }

					// data.push("\"" + ((item.personal == "") ? item.address : item.personal) + "\" <" + item.address + ">");

					datas.push(item);

				}

			}

			this.element.val(data.join(","));



			// 추가적으로 조건에 따라 변환시켜줄 수 있도록 감싸줍니다. 한글을 테스트 해봐서 변환시킨다면.

			if (printObj(datas).indexOf("\\u") >= 0) {

				var printObjOrg = printObj;

				printObj = function(obj) {

					// %uxxxx 포맷만 unescape 하기위해 한글자씩. 이전에 escape한 [{ 같은 특수문자까지 변환

					return printObjOrg(obj).replace(/\\u([a-z0-9]{4})/g, function($0, $1) {

						return unescape('%u' + $1);

					});

				}

			}

			// $("#"+this.hideId).val(JSON.stringify(datas));

			$("#" + this.hideId).val(printObj(datas));

		},

		_addTag : function(objAddress) {

			objAddress.type = this.options.type;

			this.add(objAddress);

		},

		_log : function(text) {

			try {

				// console.log(text);

			} catch (e) {

			}

		}

	});

})(jQuery);



function eventSearch(obj, event) {

	$(obj).autocomplete('option', 'minLength', 1);

	$(obj).autocomplete('search', $(obj).val());

	$(obj).autocomplete('option', 'minLength', Number.MAX_VALUE);

	event.preventDefault();

}



Array.prototype.getAddressIndex = function(objAddress) {

	var index = null;

	for ( var i = 0, len = this.length; i < len; i++) {

		var item = this[i];

		if (item.toDisplay != null && item.toDisplay == objAddress.toDisplay) {

			index = i;

			break;

		}

	}

	return index;

};



// Array Remove - By John Resig (MIT Licensed)

Array.prototype.remove = function(from, to) {

	var rest = this.slice((to || from) + 1 || this.length);

	this.length = from < 0 ? this.length + from : from;

	return this.push.apply(this, rest);

};



/**

 * ie10에서 JSON.stringify 사용할때 한글이 문제없이 보여줬었으나

 * ie8의 경우 유니코드 포맷으로 변경되는 문제발생 jquery api 예제에 있던 코드

 */

var printObj = typeof JSON != "undefined" ? JSON.stringify : function(obj) {

	var arr = [];

	$.each(obj, function(key, val) {

		var next = key + ": ";

		next += $.isPlainObject(val) ? printObj(val) : val;

		arr.push(next);

	});

	return "{ " + arr.join(", ") + " }";

};



function AddressToString(objAddress) {

	var strAddress = "";



	if (objAddress.depttype != undefined) {

		if (objAddress.depttype == "department") {

			strAddress += "D:" + objAddress.id + ":" + objAddress.name + ":" + objAddress.includeSub;

		} else if (objAddress.depttype == "share_group") {

			strAddress += "G:" + objAddress.id + ":" + objAddress.name;

		}

	} else {

		strAddress += "\"";

		if (objAddress.personal == null || objAddress.personal == "") {

			strAddress += objAddress.address;

		} else {

			strAddress += objAddress.personal;

			strAddress = strAddress.replace(/,/g, "");

		}

		strAddress += "\" <";

		strAddress += objAddress.address;

		strAddress += ">";

	}

	return strAddress;

}



function ParseRecipient(strText) {

	var objAddress = null;

	var strPersonal = "";

	var strAddress = "";



	if (strText.indexOf('@') > -1) {

		// strText가 이메일 주소로 가정

		var nIndex1 = strText.indexOf('"');

		if (nIndex1 > -1) {

			// 이름분리

			var nIndex2 = strText.indexOf('"', nIndex1 + 1);

			if (nIndex2 > nIndex1) {

				strPersonal = strText.substring(nIndex1 + 1, nIndex2);

				strPersonal = TrimAll(strPersonal);

			} else {

				// invalid

				return null;

			}

		}

		nIndex1 = strText.indexOf('<');

		if (nIndex1 > -1) {

			// 이름분리

			var nIndex2 = strText.indexOf('>', nIndex1 + 1);

			if (nIndex2 > nIndex1) {

				strAddress = strText.substring(nIndex1 + 1, nIndex2);

				strAddress = TrimAll(strAddress);

			} else {

				// invalid

				return null;

			}

		}

		if (strAddress == "") {

			if (strPersonal == "") {

				// 이 경우는 메일주소부분만 입력한 경우 (admin@nekjava.kmsmap.com)

				objAddress = new Object();

				objAddress.personal = "";

				objAddress.address = strText;

			} else {

				// personal part only, --> 검색

				objAddress = new Object();

				objAddress.personal = strPersonal;

				objAddress.address = "";

			}

		} else {

			objAddress = new Object();

			objAddress.address = strAddress;

			if (strPersonal == "") {

				objAddress.personal = strAddress;

			} else {

				objAddress.personal = strPersonal;

			}

			// return objAddress;

		}

	} else {

		// personal part only,

		objAddress = new Object();

		objAddress.personal = strPersonal;

		objAddress.address = "";

	}

	// objAddress.type = GetCurrentRecipientType();

	return objAddress;

}

