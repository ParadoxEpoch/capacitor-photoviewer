package com.getcapacitor.community.media.photoviewer.helper

import com.getcapacitor.community.media.photoviewer.R

class BackgroundColor {
    fun setBackColor( color: String) : Int {
        var backColor: Int
        when (color) {
            "white" -> backColor = R.color.white
            "ivory" -> backColor = R.color.ivory
            "lightgrey" -> backColor = R.color.lightgrey
            "darkgrey" -> backColor = R.color.darkgrey
            "dimgrey" -> backColor = R.color.dimgrey
            "blur" -> backColor = R.color.transparent

            else -> backColor = R.color.black
        }
        return backColor
    }
}
